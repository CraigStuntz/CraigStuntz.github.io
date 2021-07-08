---
title: How I Made a Giant Mistake with Terraform (and How Azure Made It Worse)
tags: azure, devops, mistakes, sql server, terraform
---

I made a huge mistake a while back, resulting in all preproduction environments being deleted from a client's Azure subscription. That's actually not so bad -- we use terraform to create the environments, so we could just run the terraform again to put them back. And better preproduction than production, right? But Azure quirks and client rules made this considerably worse. 

This was complicated by the fact that I used the terraform to provision two different Azure subscriptions, with entirely different security policies. In "Subscription A" which I provisioned first, I could do more or less anything. "Subscription B" which I provisioned second was far more locked down. Of note, in Subscription B I couldn't create an Azure Resource Group. Instead, I had to open a ticket with the client's cloud team. 

I had terraform like:

```terraform
resource "azurerm_resource_group" "resource_group" {
    name     = var.resource_group_name
    location = var.resource_group_location
}
```

...which ran fine on Subscription A, but which I could not run at all on Subscription B. There were actually two different resource groups in Subscription B, one for preproduction and one for production.

Good terraform code is idempotent, which means that if you run it in an environment which already matches the script you supply, it won't make any changes at all; it will just report that everything is up to date.

## Terraform State

In a perfect world, you would never have to think about [terraform state](https://www.terraform.io/docs/language/state/index.html). You would just run terraform and it would provision resources and everything would be lovely. Alas, this is not that perfect world, and anyone who maintains terraform must think about state when they get up in the morning, when they're working, and when they're lying in bed at night. 

The terraform docs say:

> This state is used by Terraform to map real world resources to your configuration, keep track of metadata, and to improve performance for large infrastructures.

This should set off alarm bells, because that's three entirely separate problems which got shoehorned into one hairy feature. I may have more to say about this at a later time, but let's get back to the mistake I made. 

Because I couldn't create the Azure Resource Group in Subscription B, I ran the following command:

```bash
terraform import module_name.azurerm_resource_group.resource_group <id_of_resource_group>
```

...for the preproduction resource group. That linked (in the terraform state file for the preproduction environment) the Resource Group in my terraform script with the Resource Group created by the client's team in Azure.

_Months later,_ while creating the production resources, I ran into the same issue (can't create resource groups at all in Subscription B). Since Subscription B was the one we'd be taking to production, I decided that a better reflection of the actual environment would be to change the resource group to a data provider, so I edited the terraform script quoted above to read:

```terraform
data "azurerm_resource_group" "resource_group" {
    name     = var.resource_group_name
    location = var.resource_group_location
}
```

(I've just changed the word `resource` to `data`. In terraform, a `resource` is something that terraform might create, whereas a `data` is something that terraform will _never_ create; it must already exist in the environment. But you might need to refer to properties of the `data` so it will appear in your script.)

I ran the terraform and of course it worked fine and I didn't need to do the `terraform import`.

## Terraform `plan` and `apply`

If you've worked with terraform before you'll know that there are two different things you can do when creating resources: 

  * `terraform plan` shows what the tool will do, (more or less) nondestructively
  * `terraform apply` destructively makes changes to your environment

The usual strategy is to use `terraform plan` to make sure that what terraform proposes to do is correct and then `terraform apply` to destructively make changes. But another quirk of Subscription B is that for complicated reasons that I won't get into here, I can't run terraform interactively through the command line. Instead I have to push the script to GitHub and run it with Azure DevOps. That's why Subscription A exists; I can test my changes out using the CLI there and rapidly iterate, and then push to GitHub and run terraform on Subscription B with ADO.

I say "the usual strategy" because occasionally when I'm provisioning multiple environments -- say, development, uat, production, etc. -- I will cut corners and do a `terraform plan` on just one of these environments and then  `terraform apply` on all of the others.

## Destroying Preproduction

Now you have all of the information to see the mistake that I made. Here's what happened:

1. I was working on creating the production environment, which didn't exist at all. That's when I made the edit referenced above, from `resource` to `data`
2. I ran `terraform plan` and then `terraform apply` on production and everything worked fine. No changes were made at all.
3. A while later, I wanted to add additional resources, so I added them and then ran `terraform apply` on preproduction. 
4. Terraform removed the entire preproduction environment

Wait, what?!?

Well, I had _removed_ a terraform `resource` for the Azure Resource Group. Yes, I replaced it with a `data`, but terraform still counts that as removing it. So terraform deleted the resource group. And Azure counts deleting the resource group as meaning delete the resource group _and everything in it._ Apparently, and to my great surprise, even though I didn't have permission to _create_ Azure Resource Groups in Subscription B, I did have permission to _delete_ them.

So that's bad, but surely I could just run terraform again to recreate the resources I removed, right? Well, almost. Creating Azure Resource Groups means opening a support ticket with the client, but that's not a problem. The bigger problem is that Azure SQL Server database backups are stored... in the resource group.

## A Terrible, Horrible, No-Good, Very Bad Azure Feature

Now I know that readers of this blog are smart, competent engineers, so you probably are very careful about where you store your backups! Well, Azure SQL Server does back up your databases, automatically, so full marks for that, but if you inadvertently destroy a SQL Server it takes the backups with it! Also, there is, as far as I can tell, no option in the Portal or terraform to put the backups elsewhere. (This is in contrast to running an [Azure SQL Managed Instance, which is... something else entirely](https://docs.microsoft.com/en-us/azure/azure-sql/database/features-comparison).)

Of course recreating the database is an option; we create database metadata using migrations, and it's just preproduction, so we can pretty much create the data that we need, but now the restore plan looks like:

1. Open ticket to get Azure Resource Group created
2. Run terraform to create rest of Azure resources
3. Run DB migrations to create DB schema
4. Run lengthy import process to pull MBs of data out of Salesforce and other sources

If this was production, however, we would have a much harder problem on our hands. The only places where data created by users of the system exists are in the DB and backups of same.

In the end, what we did was _not_ do any of the above and instead immediately raise a ticket with Azure Support, who were able to grab the resources from "somewhere" (I guess when you delete a resource in Azure, it's still on a disk somewhere, for a while), and we got our database and backups back. Not every resource could be correctly restored, but the database was the only one I cared about.

So in the end we got our environments back, and it "only" took a couple of days of work, what with Azure and client support tickets. But a weekend intervened, so we had several days of downtime in preproduction, and this of course had a large impact on the testers and other teams who depend on our software.

## Some Lessons Learned

Just in case I've left any ambiguity above, the root cause in this incident was me. I ran the `terraform apply`, and to whatever extent the "real" problem was "I shouldn't have been able to do that," it was probably on me for not checking that there was, in fact, a lock on the Azure Resource Group.

One of the things I did right in this incident was to _immediately_ report the problem. I posted an "I just made a giant mistake" message before the delete was even complete, before we had even considered the database. This is of course just polite, but moving quickly turned out to be the key to recovering a deleted Azure resource. Another key to recovering the deleted resource was not creating new resources with the same name before opening the ticket with Microsoft, so I give myself credit for getting Microsoft support involved before just "trying stuff" to see if I could restore it on my own before we realized that the database backups were an issue.

I guess I knew that there was the possibility that I would inadvertently destroy something when I skipped a plan, but the sheer magnitude of carnage resulting from a _one word change_ in terraform was surprising.

As far as SQL Server backups go, it's obviously totally unacceptable that a backup could be blown away so easily. I don't have a better option to suggest besides putting a lock on the Resource Group. 