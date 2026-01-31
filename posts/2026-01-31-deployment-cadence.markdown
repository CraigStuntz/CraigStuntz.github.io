---
title: "Deployment Cadence"
tags: devops, deployment
---

> "It was the best of times, it was the worst of times..."
> -Charles Dickens

My first professional software development job was producing statistical analysis
and simulations of physics experiments at the 
[AGS accelerator](https://www.bnl.gov/rhic/ags.php). My deliverable was the 
_output_ of the software, not the software itself. Therefore, a "deployment" 
meant "recompiling and executing the software on my local machine." This was
awesome, in spite of the fact that I wrote the software in FORTRAN. My cycle 
time was soooo low! 

My second professional software development job was working for an 
[ISV](https://en.wikipedia.org/wiki/Independent_software_vendor) starting in 
1999 (Y2K fixes!). We produced client/server software which other businesses 
would install on their local networks. A deployment meant building the software
(during my stay there we went from building it on a developer's local machine to
using a dedicated build system) and burning it onto a CD-ROM. After some testing 
the CD-ROM would be mailed to customers (yes, through the postal system, and 
accompanied by printed, bound manuals), who could
then (optionally!) install it on their systems. We did this roughly once per 
quarter.

Decades later, these two jobs represent the fastest and slowest release cycles, 
respectively, I've experienced.

## Continuous Deployment

I will be using the phrase "continuous deployment" in this post to mean 
"as soon as you push a commit, that change is integrated and deployed to 
customers." I want to call this out because it is different from continuous 
integration or continuous delivery, which do not necessarily result in your 
changes being immediately visible to customers.

The [DORA metrics](https://en.wikipedia.org/wiki/DevOps_Research_and_Assessment#DORA_Four_Key_Metrics)
encourage us to optimize the deployment process as much as possible. Three of 
the four metrics, "Change Lead Time," "Deployment Frequency," and 
"Mean Time to Recovery" tend to improve if you can get code changes in front of 
customers as quickly and as frequently as possible. For good reason, I think. 
[Others have written about this](https://itrevolution.com/product/accelerate/),
so I won't go into detail, but I do think that shipping software frequently 
minimizes both the time to receive feedback and the overall impact of any bugs 
in the new version. It forces you to think about how to make the overall 
experience of an upgrade to a customer as non-disruptive as possible.

However, and this is what I _actually_ want to examine in this post, the phrase
"**as frequently as possible**" is doing a lot of heavy lifting here. What does "as
frequently as possible" actually mean? 

It depends.

## Constraints on Deployment Frequency

Let's assume, for the sake of argument, that your goal is to deploy as fast as 
possible: You change a line of code, and you can instantly 
test it in production. (Perhaps you disagree that this is a good idea, but I think
it does represent an extreme case of deployment speed, so it's a _useful_ 
scenario to examine.) One big advantage of this model is that it forces you 
to eliminate customer downtime in deployments. 

### Inefficiency

There are some things that tend to slow this down which we can handwave away as
inefficiency. For example, a compile/build/automated test/deploy step might 
_take time,_ but perhaps this could be greatly optimized? Some very lengthy 
tests, such as fuzzing, can be run post-deployment or split into pre- and 
post-deployment phases. I think "testing in 
production" can actually be a very correct and practical thing to do in many 
cases. It can be the only way that you find certain performance issues prior to 
customers finding them. Depending on the scale of your production system, doing 
a load test in a preproduction environment may not be representative of the 
actual user experience in production. You can fix these with another update, 
hopefully before a customer sees them. 

### Trust

Other factors are harder to dismiss as inefficiency, though. Remember my second 
job? The customers would decide when _or if_ they wanted to install the update
on _their hardware._ We live in an age where vendors seem to want to control
which updates are installed on hardware we own, but I do cling to a somewhat 
romantic notion that we should control our own devices. Now I may _choose_ to 
let the OS vendor install critical security patches without notifying me first, 
but it is my choice. Similarly, you need to build a lot of trust with a customer
who has hundreds or thousands of employees working on software that you produce
before they will let you update it on your schedule, during their critical work. 
If you tend to badly break
the software during an "upgrade," the customer will want to minimize updates or 
confine them to less critical times.

### Complexity 

Also, deploying to a customer environment might not be simple! I loved 
[this talk, "Update on Update," by David Pacheco](https://www.youtube.com/watch?v=M-ZLz8Wg34s&t=1s)
about how [Oxide](https://oxide.computer/) is improving their update process. Their existing 
process is essentially "an Oxide employee updates the software remotely." The
process they want to move to is "a customer can download and run a self-service program which
will do the update." _Both_ of these scenarios currently involve downtime on the
rack, but they would like to minimize or eliminate downtime. Automating the 
update, unsurprisingly, turns out to be a _very hard problem,_ for reasons 
which _mostly_ boil down to "there are _a lot_ of interdependent components on an Oxide 
rack." One other limitation discussed in the talk is that some of the production
Oxide racks are air-gapped; simply pushing software over the internet is not an 
option for these. So there are two overall limits on deployment frequency here: 
The first is that the upgrade process is not currently simple and Oxide is working very 
hard to make it an "execute a script" experience. The second is that the Oxide 
rack owners will still get to choose when to apply an update. Dave's talk is 
fantastic; I recommend you watch it!

### Gates

If you're developing a native mobile app (or another app store with a review 
process), deploying to an end user might be a 
several weeks long back and forth between you and an app store reviewer in the 
worst case, and [many hours on average](https://www.runway.team/appreviewtimes).
"Instant" deployment to a mobile user is simply not possible with a native app.
[Apple recommends continuous delivery](https://developer.apple.com/documentation/Xcode/About-Continuous-Integration-and-Delivery-with-Xcode-Cloud) rather than 
continuous deployment.

For other types of applications, even the hardware owner might not have the 
option of saying "please update our systems
continuously." I have worked in heavily regulated environments (utility billing)
where upgrades to some parts of the system needed to be reviewed by government
regulators before they could be deployed. This imposed a hard limit on 
deployment frequency. I have heard similar stories about people who produce 
software which is used in classified environments. In such cases you can 
_discuss_ increasing the deployment frequency with the gate managers, but it's 
never guaranteed that they will say yes!

## How Fast Is Too Fast?

Above, I assumed that you are trying to deploy changes to production as fast as
possible: "You change a line of code, and you can instantly test it in 
production." I do not actually believe this is a good idea! In practice, I want
to, at a minimum, run a compiler, linter, unit tests, integration tests, security
scans, etc., before deploying. In other words, the standard integration process. 
Before I do that, I'm going to manually test my changes locally, and in many 
cases I will ask another developer to review them. This takes time, which I 
think is time well spent!

> "Any observed statistical regularity will tend to collapse once pressure is 
> placed upon it for control purposes." -[Charles Goodhart](https://en.wikipedia.org/wiki/Goodhart's_law)

The danger with metrics, of course, is that you can pursue them to make the 
"line go up" instead of looking at what you are actually trying to measure. I 
do think that the DORA metrics are some of the most useful measurements that 
one can make about a software project, but the results should be discussed, 
rather than shown on a dashboard. Skipping peer review of important changes to 
shave a few hours off of your Change Lead Time would be a bad trade, I think!

Similarly, some of the hours spent waiting for app store approval is Apple or 
Google doing automated vulnerability scans on your apps. A developer can of course do 
do this themselves, but experience has shown that not everybody bothers.

So when you hear phrases like "you should deploy changes to customers as fast
as possible," I think it's important to hear "as fast **as possible**" rather 
than "**as fast** as ..."

## One Size Fits Most

"One size fits all" clothes tend to be a compromise. They never fit as well as a 
tailored garment. Similarly, I am suspicious of people who assure me 
that continuous deployment is always possible or even desirable in _every 
situation._ I think that continuous deployment is a _reasonable default position_ 
for starting a discussion about deployment, but I do not think that it is always 
the best strategy. Continuous deployment can be useful as an "ideal" even in 
cases where a huge (and perhaps insurmountable, given other business needs) 
amount of work is necessary to make it happen. 