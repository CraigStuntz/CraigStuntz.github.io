---
title: Telling the Turth About Security
tags: human factors, James Morrow, security
---

In James Morrow's wonderful novella _City of Truth,_ people in the city of
Veritas have been conditioned to tell the full, unvarnished truth in every 
situation. They drive a "Renaut Adequate," send their children to Camp 
Ditch-the-Kids, and always pay their bar tabs. The warning on cigarette 
packs reads:

> <font style="font-variant: small-caps">WARNING: The Surgeon General's crusade 
> against this product may distract you from the myriad ways your govenrment 
> fails to protect your health.</font>

I think about this often in the context of security messaging for 
people who use the software we produce. Real warnings on cigarette packs are 
one of the few examples of honesty in packaging we have today, but that's not 
good enough for Veritas. 

What is the right amount of honesty for messaging to the end user? Clearly 
<em>dis</em>honesty is bad, but so is a dissertation-length discussion of encryption 
parameters. If our assessment of real-world 
threats creates an excessive paranoia in end users, convincing them that
<abbr title="Advanced Persistent Threat">APT</abbr> crews are coming for 
their kids, then our "honesty" becomes dishonest.
I would assert, without a lot of evidence to back me up, that the
right amount of honesty is that which enables the user to make good decisions
about their behaviors, _within the application's threat model._

That "within the application's threat model" hanging off the end is what 
allows me to say that things which are true but distracting should not be 
included in security messaging.

## Want to Start an Email Service?

I was thinking about this in the context of some [tweets from Nathan Buuck. He 
wrote](https://twitter.com/i/status/1286700216742293505):

> I'm curious to sign up for an email service as a new user and see what they 
> warn you about as a presumably-new email user. I imagine most services - 
> especially those that want to keep you for ad revenue - don't give you a full 
> explainer for fear of scaring you off.
> Ethically, though, every new email user should be given a briefing about how:
> 
> * you can't trust anything you see in email at face value 
> * your digital identity will grow to depend existentially on this email account 
>
> And the litany of other concerns.<br/>
> Failing to prepare new users by not illustrating to them the potential scope of the 
> risks _we know_ they may face is just negligence.

Well, you can tell that these are good questions because there's a ton to unpack
here.[^advertising]

One thing that's interesting to me here is the difference between Nathan's two
bullet points. To whatever extent the first point is correct, it means that 
the security of the _email_ service has failed. Whereas to whatever extent the 
second point is correct, it represents a failure of security that's the 
fault of nearly everyone _but_ the email service. I'll explain more below. 

Because the risk of compromise through email is so high,
we're at a real risk of erring on the side of over-explanation, especially if we 
try to explain it all at once, but even if we don't. If we consider only
email, only security, and only the items which all users need to 
understand,[^only] that's at least:

* Basic scam detection — if it looks too good to be true...
* Phishing, credential harvesting 
* Spearphishing, and why not to wire money to your boss
* Basic identity/password hygiene, multi-factor identification
* Physical security — don't go meet strangers you've corresponded with
* Dark patterns in advertising
* Common user misbehavior, such as chain emails

This is a lot for a user who signs up in order to stay in touch with their kids 
to take in! But the security scope creep will start immediately, partially 
because of the actions of criminals, but partially also because of the decisions
of the security community.

### When Should We Explain This?

I don't think that during sign-up is the correct place for explaining what you can 
and can't trust in an email. The right time to explain phishing is 30 seconds
before you are phished. It's not always clear when this will happen, but I think
it's fair to say that during the sign-up process is perhaps the _least_ likely 
time that the user will be phished in email. Putting this in onboarding feels 
like a legal cop-out to me: "We told them; what else could we do?"

But there is a responsibility to explain this stuff at some point! The old 
model of an email client blindly displaying whatever you send it doesn't reflect
the reality of a hostile world. Today, for example, Gmail will tell you if someone 
you correspond with suddenly begins emailing you from a new address. Maybe it's 
someone trying to spearphish you, or maybe it's just JIRA. At any rate, such emails 
deserve extra scrutiny! Putting this on the suspicious email itself is a much
better solution than putting an explanation on the screen during signup.

### What Do We Ask Users to Trust?

Since Nathan's question asks what email services display to new users, I'd like
to reframe this point in terms of the service provider: What does an email
service ask its users to (dis)trust?

When Nathan says, "Failing to prepare new users by not illustrating to them the 
potential scope of the risks we know they may face is just negligence," he's 
not wrong, but we have to be really careful about sentences like this, because 
they include risks both inside and outside the threat model of the service. For
example, training is the _wrong approach_ to the problem of "attachments in email 
might harm your computer." The right approach is to make clicking on attachments 
in email safe, not relying on end users to make good security
decisions 100% of the time. 

Indeed, nearly every company has people in HR who must click on PDF files 
attached to emails from random strangers on the Internet as an essential function of
their job! We can't tell people "Hey, don't do your job; it's not safe." We have
to give them an email client where this mundane action is safe.

#### Example: Phishing Simulations

Implicit in the notion of what an email service should disclose to / train users
about is the presumption that we even know what to tell them at all. 
Unfortunately, we cannot take this as a given.

Phishing simulation has become fairly big business these days. It makes sense, 
as phishing is often the attacker's first foothold into an enterprise. It's 
important to have clear goals for the phishing simulation, since, like a red 
team test, the attackers always win.[^Hadnagy] If you conduct a phishing 
simulation and nobody is fooled, then your simulation was unlike an actual 
phish, which will probably result in users being deceived.

Therefore, if the purpose of your simulation is to determine if anyone will 
fall for a good phish, I can save you the money: Yes, they will. If you fire
everyone who falls for the first phish, like some perverse form of stack 
ranking, then you'll have more people who are taken in by the second. However,
phishing simulations can be useful if you have constructive goals in mind.

> "Lets be honest with each other. Phishing simulations aren't just about 
> training. They are also popular because they produce a metric (e.g. 'Last week 
> 60% of people fell for our phish, this week only 35% fell for it'). It appears 
> really positive and encouraging, since it appears to show that something is 
> being achieved, but unless you're careful you might just end up wasting time 
> and effort."<br/>
> [_"The Trouble with Phishing,"_](https://www.ncsc.gov.uk/blog-post/trouble-phishing)
> Kate R, National Cyber Security Centre, UK

Here are some constructive goals we might set for a phishing simulation:

* Train users to send phishes to the 
  <abbr title="Security Operations Center">SOC</abbr>, giving the blue team a 
  heads up on what's in the field
* Train users how to respond if they click on a phish and enter their 
  credentials. If we can train users to call the 
  SOC immediately instead of 
  keeping quiet and hoping nobody notices, that's a big win!
* Increase the level of end user skepticism about what's in email. I feel 
  a little weird about including this, since, as I said, the phishers will 
  always win. But we can certainly make them win less if we treat this as 
  proactive training, not punishment for people who click on a phish.

Unfortunately, if you look at the promotion materials for phishing simulation 
software, they're all graphs of "number of employees caught," which suggests
that security management is pursuing metrics instead of better security. This 
attitude is noticed by employees, who start to regard the security team as 
people who are out to "catch" them, because they are. If we train employees to
distrust the security team, we have badly failied at our job.

This is a good example of why technical or legal controls are not enough to 
protect users of an email service. The training we give must be informed by 
human-centered, compassionate support for people. Running it by the corporate 
equivalent of an [IRB](https://www.irb.pitt.edu/content/chapter-2-purpose-human-research-protection-office-and-institutional-review-board) 
would not be a bad idea. And we must repeat this 
introspection with every control on our list.

### Your Identity Source of Truth

To Nathan's second point, "your digital identity will grow to depend 
existentially on this email account," well, that's correct, but it's interesting
to note that this is not because of some technical factor which makes email the
unique thing that is the only possible source of truth for identity, but rather 
because, in a nutshell, the entire industry has decided that email — and by 
"email" we mean Gmail, mostly — does security 
well, and therefore the source of truth for identity should be Gmail. 

As evidence for this, consider that it was pretty common to use 
[SMS as a source of truth for identity](https://mashable.com/2017/06/16/twitter-two-factor-authentication-major-problem/) until it became obvious that 
[SMS could not be trusted](https://www.engadget.com/2020-01-12-princeton-study-sim-swap.html).
Services are moving away from SMS, and Gmail is the last thing standing. 
Even sites supporting MFA — a minority! — often use email as a portion of their 
password reset process. 

This would be less of a security choke point if people always made a unique 
email address for each web account they created, but almost nobody does this.
So if your email is compromised, Nathan is correct, the bad actors get every 
account you have, including retirement accounts (your life savings, 
uninsured), potentially embarassing accounts, etc.

It will be interesting to see if WebAuthn, which doesn't require an email 
address and appears to be secure, has similar uptake in the future. It will also
be interesting to see if the uptake of less secure email services will 
result in people moving away from email as the identity source of truth. The
[Yahoo! breach](https://en.wikipedia.org/wiki/Yahoo!_data_breaches) did not 
push developers away, though, probably because the other 
options were all worse.

### Do I Want to Start an Email Service? Hell, No!

One thing is very clear to me: When you start an email service, to whatever 
extent you're successful and your service becomes popular, you are painting a 
giant target on your back and on the backs of your users. Your security team
— meaning not just your blue team but also the people who work with human 
computer interaction in the security space — must be very good, the best people
in the industry. If you don't want to take that on, you have no business 
starting an email service. 

One hip email service brags that they "engaged two 
separate, external security firms to review all our application security." That
simply doesn't cut it; it's laughably inadequate for the task at hand. How would
hiring an external team protect users from a phishing attack? The problem of 
email security is just much larger than technical controls. 

## Leaving Veritas

In _City of Truth,_ the protagonist, Jack Sperry, falls in with a group of 
(literally) underground rebels who sometimes lie. He meets his roommate, Ira 
Temple. 

> Ira, I learned, was a typical dissembler-in-training. He hated Veritas.
> He had to get out. Anything, he argued, even dishonesty, was superior to what
> he called his native city's confusion of the empirical with the true.

I hope by now it's clear why I don't think it's sufficient to "tell the truth" 
about security; we must have a more nuanced conversation which is not just at
sign-up and continues throughout the user's use of the service. It must always
be informed by the amount of information a typical user can take in at any one
point in time. "Confusion of the empirical with the true" describes a lot of 
mistakes we make in software.

[^advertising]: I do think advertising is a red herring here. The two points in 
the tweets, while really worth discussing, don't change with or without ads. 
Indeed, a very well-known email service with ads also does a better than 
average job identifying what you can or cannot trust in email. I think ads are
orthogonal to these questions. 

[^only]: By "only email" I mean to exclude things like encryption which are
security-related but not directly relevant to basic email use. By "only 
security" I'm excluding things like how to compose and send emails, which are 
really important for new users, but out of scope for this article. By "only
the items which all users need to understand" I'm excluding things such as 
nation state attacks, which are security related and relevant to email, but 
not something that the average user needs to think about.

[^Hadnagy]: Nobody, and I mean nobody, is immune to phishing. The organizer of 
the DEFCON Social Engineering Village recently 
[shared his story of getting phished](https://youtu.be/9e6k_PtEXdM?t=566).