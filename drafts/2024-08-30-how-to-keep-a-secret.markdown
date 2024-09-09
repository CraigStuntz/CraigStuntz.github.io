---
title: "How to Keep a Secret"
tags: security
---

As software developers, we are regularly tasked with keeping secrets, such as 
passwords, certificates, API credentials, signing keys, etc. We know that 
you shouldn't just check them into a git repository. But are the alternatives, 
like, say, adding them as GitHub Actions Environment Secrets, really any better? 
Keeping secrets secure is one of the things we need to get right, and getting it 
"mostly correct" is not good enough.

When asked to keep a secret secure, the first instinct of the average programmer 
is to put it behind a password. 
[As the saying goes](https://regex.info/blog/2006-09-15/247), “Now you have two 
problems.” How can we actually improve security?

Secrets are more complicated than they might at first glance seem, in part 
because there are so many different types of secret. 

<div class="highlight">
However, there is one key 
fact which we can use to simplify the entire enterprise, which is that an 
effective way of keeping secrets, well, secret, is to _have fewer secrets._
</div>

In 
this post, we will examine some practical ways of reducing the number of secrets
we must keep, and some better ways to deal with those that remain.

## What Is a Secret?

A secret is any value which you only want to disclose to certain individuals or
systems, and where the disclosure of that value is itself a security compromise.

One of the recurring themes of this article will be that not all secrets are the
same, so let's first consider some things which you might want to keep secret:

* Passwords
* ATM PINs
* [PII](https://www.dol.gov/general/ppii)
* TLS certificates
* API Keys ("client secrets")
* Proprietary code (or access to same)
* SSH keys

...and many others!

## Is There a "Silver Bullet" Solution?

The programming profession has developed a variety of different ways to deal
with secret-keeping over the years, including:

* **Hash passwords** using bcrypt or scrypt and then store the hash
* **Store passwords** in 1Password/Chrome Password Manager/macOS Keychain, etc.
* **Third party services** such as Azure Key Vault or AWS SSM Encrypted Parameters
* An **[HSM](https://en.wikipedia.org/wiki/Hardware_security_module) or 
  [PAM](https://www.microsoft.com/en-us/security/business/security-101/what-is-privileged-access-management-pam)** solution, such as CyberArk or Delinea
* **[MVP](https://www.scrum.org/resources/blog/minimum-viable-product-or-minimum-inspectable-increment) 
  solutions**, like Docker Secrets or GitHub Actions Environment Secrets
* **Physical security**, such as putting passwords in a safe

All of these "solutions" do some things well, and are wildly unsuitable in other
cases:

* bcrypt <- can’t decrypt, so unsuitable for client secrets
* Chrome Password Manager <- not intended for non-interactive (service) use, must trust vendor
* Cloud services <- Costs money, not available on all devices, mostly useful for client secrets
* HSMs/PAMs <- Expensive, centralized design might make outages catastrophic
* MVP solutions <- Tend to put ease of use over security in order to provide a viable alternative to keeping secrets in plaintext
* Physical security <- How do you get it when you need it?

Every method of dealing with a secret has downsides. You need to choose the right
compromise for your threat model, presuming that you cannot eliminate the secret.

What's more, even if you do _literally everything right,_ your secrets may still
be stolen. For example, a threat actor who Microsoft calls Storm-0558 was 
[able to access Exchange email boxes by forging security tokens through compromise of a Microsoft key](https://www.microsoft.com/en-us/security/blog/2023/07/14/analysis-of-storm-0558-techniques-for-unauthorized-email-access/).
In this case, the owners of the Exchange Online email servers were following 
good practices and had delegated the security of their secrets to a much larger,
technically competent, and well-resourced entity (Microsoft), and had their 
secrets stolen anyway.

So perhaps we should be asking not "Is there a magic solution for all secrets,"
but rather "Is there any solution for _any_ secret?" 

## Eliminate the Secret!

The answer is yes: If you can eliminate the secret altogher then you prevent 
its theft. 

Although 100% of secrets in an organization cannot be eliminated, a surprising 
number can. Let's take a look at some practical examples.

* Get rid of old PII. The default of nearly every database is to store data 
  forever, but ask yourself if you really need every bit of data that you 
  captured years ago online. You can write a nightly sweep which deletes old 
  records or moves them into cold storage.
* Use [identity based access to cloud resources instead of client IDs/secrets](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure-identity)
  in a build server.
* Similarly, don't give the build server direct access to create/manage cloud
  resources. Instead, have a Lambda or Azure Function which has that permission
  and trigger that function on a queue that the build server can put messages 
  on.
* Control access to a database using 
  [managed identity instead of with a password](https://learn.microsoft.com/en-us/azure/app-service/tutorial-connect-msi-azure-database?tabs=sqldatabase-sc%2Cuserassigned-sc%2Cdotnet%2Cdotnet-mysql-mi%2Cdotnet-postgres-mi%2Cwindowsclient).

## Threat Modeling

However, there's a subtlety here that I don't want to gloss over. The PII that 
one system stores is different than the PII in other systems, and the 
consequences of the compromise of one secret is not the same as the compromise 
of another. The threat models of irs.gov, Microsoft Azure, and Bob's
Pizza, LLC, are all different.

Your threat model should guide every security decision you make. A threat model is:

* What you have, technically
* Who (which people) you are protecting
* The specific bad actors who will attack you

All secrets that your software or system keeps should be in your threat model. 
For each threat in the threat model, you must make one of four possible decisions: 

* **Accept** the threat. Choose to do nothing, often because the risk is low and "you 
  have bigger fish to fry." Keep the threat in the threat model, though!
* **Eliminate** the threat altogether. Stop using or storing the secret, for example.
* **Mitigate** the threat. E.g., "We reduce brute force attacks through use of a 
  [WAF](https://en.wikipedia.org/wiki/Web_application_firewall)."
* **Transfer** the threat. E.g., "We use Azure infrastructure to manage our TLS
  private keys and never give direct access to them to our own employees."

As the saying goes, "Your threat model is not my threat model." Every 
organization will have its own threat model, and it will change over time. Your 
organization should continually revisit this.

When you are asked to make a change which affects the security of your product,
it's helpful to see where that change falls within the threat model and use that
to guide you as you work.

## Not All Secrets Are the Same

Let's examine some general classes of secrets and where they fall within the 
four possible decisions we can make for items within the threat model (which, 
again are accept, eliminate, mitigate, and transfer).

### Passwords

By a "password," I mean "some value that a human being will enter to control 
access to a resource." These are different from a "client secret," which I will
discuss later on. I feel the need to clarify this, because our industry has been
a bit free with language, and calls, for example, "a secret which a service uses
to access a database" a "password," when really it's a client secret. Anyway...

Look, passwords are a disaster. Most users use same passwords in multiple sites.
Passwords are phishable, without a password manager, which most people don’t 
use.[^passwordPhishing] However, we're kind of stuck with them, both due to 
legacy use and due to the disadvantages of some of the systems proposed to 
replace passwords, such as federated identity and passkeys.

So we must understand passwords well, and use them correctly. Not all passwords 
are the same! Some are memorized (probably your laptop password, for example), 
and some are random values stored in a password manager.

A _key property_ of a password is that it's never necessary to store the 
plaintext of the password on the server, and it should not be stored in a 
decryptable form. If possible, delegate this security-sentitive work to a service
such as Authentik, Okta, Entra ID, etc. But it's still worth understanding that 
these services cannot decrypt a user's password at all, and instead use a 
mechanism such as bcrypt or scrypt to store the user's password hash.

A password can be combined with MFA, but SMS MFA is also phishable. 
[Other methods of MFA, such as FIDO keys, are not phishable](https://www.cisa.gov/sites/default/files/publications/fact-sheet-implementing-phishing-resistant-mfa-508c.pdf). 

Beware of nebulous "best practices" regarding passwords, such as 
[weird rules which are depressingly common in large sites](https://passwordshamer.com/).
Instead, I invite you to read 
[NIST 800-63](https://www.nist.gov/identity-access-management/nist-special-publication-800-63-digital-identity-guidelines), which is based on
research, clearly explains why it makes the recommendations that it does, and 
overall is one of the more enjoyable and informative government standards 
publications which I have read. One really useful concept from NIST 800-63 is 
the "assurance level," which ties in closely with the threat model, and in 
particular the realization that everyone's threat model is different.

### Passkeys

A [passkey](https://passkey.org/) attempts to do a 1-for-1 substitution of 
passwords with a secure, phish-resistant, usable alternative. Sounds great, 
right?

Maybe! It's early days yet. Support for passkeys is both very new and 
[varies by platform](https://www.corbado.com/blog/passkey-implementation-pitfalls-misconceptions-unknowns). 
Different organizations have implemented passkey support for their 
sites totally differently, with some sites inexplicably still wanting a password
even after a user has logged in with a passkey. 

The end user of a passkey must make a choice whether to store passkeys in Apple, 
Google, 1Password, etc., and this choice is not always presented in a clear way.
I would not currently recommend passkeys to my “non-technical relative.” 
Hopefully this changes as the technology matures. 

But for now, I would put passkeys in the "promising, but not totally ready for 
prime time" bucket.

### Client Secrets

A client secret is a secret which a service account can use to get access to a 
resource, such as an AWS access key and secret pair. At first, it would seem to 
be the same as a password, but the rules for keeping a client secret secure are 
totally different.

A _key property_ of a client secret is that it must be available in decrypted 
form on the server. This is totally different from how passwords are stored.

Also, a client secret is not usable with a FIDO MFA key, or TOTP apps 
such as Google Authenticator, etc. There may be "second factors" usable with 
a client secret, such as the originating IP address or mutual TLS, but they are
different than the second factors used with a password.

Because client secrets are not intended for use by a human, the rules regarding
rotation and complexity are entirely different from passwords. It may make sense
to require rotation of client secrets, and they need not be memorizable. 

### Trade Secrets

A trade secret refers to information known to an employee of an organization 
which is not generally known to the public and which conveys some benefit to the
organization. One example which a lot of programmers will recognize is an 
organization's source code, which is often secret.

The safest assumption to make with a trade secret is to assume that the secret
is compromised. This doesn't give you permission to be reckless with your 
security regarding the secret, but you should be careful about using it to store
other secrets. Groups such as Lapsu$, Nobelium/Midnight Blizzard for whatever 
reason really like stealing source code. You should use a scanner such as 
[TruffleHog](https://trufflesecurity.com/trufflehog) on your repositories, 
because the chances are high that your adversaries already are.

### PII

PII, or Personally Identifiable Information, is really simple to handle: Store as 
little of it as possible, and delete it quickly as soon as you can (note that 
there may be legal rules requiring you to retain _or_ purge certain kinds of PII).

Unlike most secrets, PII must typically be presenteed as plaintext in the user
interface of an application. You should assume that it's compromised. It's 
always a liability. If your client secrets are stolen, that's bad, but it 
probably won't make your organization headline news. PII is a fast path to 
headlines.

Not all PII is the same, and it isn't the same for every site. If a site leaks 
the name of its users, well, that's one thing if it's 
[the names of voters](https://www.csoonline.com/article/554111/database-configuration-issues-expose-191-million-voter-records.html) and quite 
another thing if they're the [customers of an addiction services provider](https://www.vpnmentor.com/news/report-confidanthealth-breach/).

For every single piece of PII that you think you need, ask if there are no 
alternatives and how long it’s needed. If you are told that you need some PII, 
and there is no alternative, you can ask for legal review.

### Non-secrets

It's helpful to be explicit about what actually isn’t a secret. This will vary 
by project and by threat model. In fact, it's so varied I don’t even want to give 
an example. The product manager might say that usernames are PII and therefore a 
secret, but if the company’s reaction to them leaking is to shrug and not even 
offer "free credit monitoring," then it's hard to consider that a secret.

## Recommendations

Have fewer secrets. Give them less power. Make policies regarding their storage
and use. For example, if your database server supports connections via managed
identity, then use that feature instead of a password/secret to connect to the
database, both as a developer and in production, from a service account.

Be ruthless in eliminating PII in your system. Don't store it at all when it's 
not strictly necessary to keep it, and if you must keep it, delete it as soon
as possible. 

Assume compromise of your trade secrets, and make them as "not valuable" as 
possible. For example, use a secret scanner in a pre-commit hook to keep other
secrets out of your code.

Set a company policy for secret storage and beware of widely distributing 
secrets by accident. Developers tend to handle a lot of secrets and will hence
tend to create "informal secret stores" in the absence of policy. Some organizations will say, 
"developers need to install a lot of software, and so they need administrative
access to their machines." But I'm a developer, and most days I'm not installing
software. Having _temporary_ access to administrative privileges is just fine for
me if it's not a hassle; in a sense this is like using `sudo`.

### Build Servers

Build servers tend to have very, very, very privileged secrets, and they don't 
necessarily do a good job of keeping them safe. Jenkins has had a kind of iffy 
security track record, to put it politely, and GitHub Actions Environment 
Secrets are “better than storing secrets in plaintext.” Can we do better?

Yes, we can, by elminating secrets! Let's take as an example a build which runs
in GitHub Actions and which needs to check out code, build it, save an artifact,
and then deploy that artifact to production servers. By virtue of running in 
GitHub Actions, the build can check out code and save an artifact without needing
a secret, but what about deployment? 

First, 
[GitHub Actions can connect to Azure through managed identity](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure-identity). Second, the build _itself_ does not need 
to actually do the deployment, it simply needs to _cause deployment to happen._ 
This distinction means that we do not need to give the build process permission
to directly control Azure infrastructure, which means we can eliminate a high
value secret. Instead, the build, which has connected to Azure via identity, 
can put a message into a queue which will cause an Azure Function to actually 
do the deployment. The Azure Function has permission to change infrastructure,
not the build. 

### Transporting a Secret

Presuming that you can't elminiate a secret, and have a good way of storing the
secret, how do you get it from the point of storage to the place where it is 
used?

The classic technique is to use environment variables (or Spring properties, 
etc.), and while this does have some benefits (it keeps the secret out of your
source code, and it's easy to use temp values during development), we should ask
if we can do better. Accessing the secret from the API of the vault where it is
stored prevents areas of your application which might have access to the 
environment, such as [Spring Boot Actuator](https://docs.spring.io/spring-boot/docs/2.5.6/reference/html/actuator.html),
from disclosing the secret. Azure Key Vault has 
[a way to shim this API access over use of the environment which is very convenient](https://learn.microsoft.com/en-us/azure/app-service/app-service-key-vault-references?tabs=azure-cli). Using this method
you can access secrets in code as though they were environment variables, but 
when deployed to Azure the actual lookup will be done using the Key Vault API 
and the secret value will not be in the application's environment. 

### Proactive Notice of Secret Leaks

If your secret leaks (and it's only a matter of time, to be honest), then you
want to proactively know this so that you can rotate the secret and clean up the
mess. 

One way to get a high-fidelity alert when your secret leaks is to use a 
[canary token](https://canarytokens.org). For example, you can create a real AWS 
client ID and secret that you can leave on a production server. If an attacker 
finds it and tries it out, then the canary will send you an alert via email. 
There are many different types of tokens available. 

One of the value-adds of third-party services for secret handling is that they 
will often consider additional signals when deciding when to accept a secret. 
If you usually log into a site from Pennsylvania during working hours, and you 
suddenly are connecting from overseas at 3 in the morning, the service may want
additional verification that it's really you.

Many WAFs have built-in intelligence which can detect a brute-force password attack 
against your site. There's not much you can do about these attacks besides block
the requests, but just knowing about them can be useful. 

## Cheat Sheet(s)

Questions to ask when you are dealing with a secret:

* Can I avoid using a secret (in this place) at all? (E.g., store less PII, use federated auth.)
* Do I understand what kind of secret is needed? (E.g., understand the difference between passwords and client secrets.)
* Can I narrow the blast radius if leaked? (E.g., use an IAM role and limited account instead of an admin account.)
* Can I narrow the scope of the secret use? (E.g., with “just in time” access, e.g., PAM.)
* Can I "make it Amazon's problem": use an “off the shelf” service instead of writing code myself? (E.g., Okta, Authentik, Entera ID, …)
* How do I minimize exposure of the plaintext? (E.g., use SAST, consider alternatives to environment variables)
* How can I detect attempts to compromise the secret? (Logging, WAFs, etc.)
* How can I proactively know if the secret is leaked? (Logging, again, and canary tokens)

Finally, this is less of a “Cheat Sheet” than a "Secret Management Longread," 
but the OWASP Foundation has a [Secrets Management Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html).

[^passwordPhishing]: See, for example, [this study from BitWarden](https://docs.google.com/presentation/d/1KaJtB4SBaZjeUiXrWzuioGKQgUWGm1oWPnWvb0FF6iw/edit#slide=id.g11b2737de95_0_325)