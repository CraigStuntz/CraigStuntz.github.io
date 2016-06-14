---
title: Presentations
---

### Incredibly Strange Programming Languages
* [Stir Trek](http://stirtrek.com/)
· 6 May 2016
· [Slides](https://speakerdeck.com/craigstuntz/incredibly-strange-programming-languages)
· [Video](https://youtu.be/pwrYx-tdpn4?t=3m14s)

If you've ever suspected that “all programming languages are pretty much the
same; they just have different syntax,” well, you will never suspect that again!
Covering languages from the unusually powerful (Idris) to the illuminated (قلب)
to the profoundly limited (BlooP), and all points in between, these languages
will help you think differently about approaches to software problems you face
in your day job. Of course we’ll have a lot of fun, but these languages are no
joke. The practical benefit of an impractical language is the power to find new
approaches to common problems.


### Programs that Write Programs: How Compilers Work
* [CodeMash](http://www.codemash.org/)
· 7 January 2016
· [Slides](https://speakerdeck.com/craigstuntz/programs-that-write-programs-how-compilers-work)
* [Dog Food Conference](http://dogfoodcon.com/)
· 8 October 2015
· [Slides](https://speakerdeck.com/craigstuntz/programs-that-write-programs)

Compilers are the bridge between the code you write and the applications you run. While production compilers can be quite complicated, the principles of compiler design are not too hard to learn, and are broadly applicable to many seemingly difficult programming problems. In this session you will learn how every phase of a real compiler works, including lexing, parsing, type checking, optimization, and code generation. The lessons learned here will help you with many common programming problems, such as deserialization, maintaining large amounts of legacy code, static analysis, testing, and validation. Full source code for a working compiler targeting the .NET CLR will be included!

### The Limits of Testing and How to Exceed Them
* [QA or the Highway](https://qaorthehighway.com/)
· 16 February 2016
· [Slides](https://speakerdeck.com/craigstuntz/the-limits-of-unit-testing-and-how-to-exceed-them)
* [Dog Food Conference](http://dogfoodcon.com/)
· 8 October 2015
· [Slides](https://speakerdeck.com/craigstuntz/the-limits-of-testing-and-how-to-exceed-them)

Your unit tests pass and your code coverage looks great, so you can just hit “Deploy" and head out for the weekend, right? Unfortunately, passing tests, while useful, do not guarantee that your system works correctly. We can do better! Techniques such as property based testing, fuzzing, dependent types, and manual testing can be combined with unit testing to ensure highly reliable software. How do you know when you are really, truly "covered" by a unit test and when you must employ other techniques? You will learn precisely what unit testing really does, what it can never do, and how to create the best plan for ensuring the overall quality of your application.

### How to Use Real Computer Science in Your Day Job
* [Lambda Jam](http://www.lambdajam.com/)
· 15 July 2015
· [Slides](https://speakerdeck.com/craigstuntz/how-to-use-real-computer-science-in-your-day-job)
· [Video](https://www.youtube.com/watch?v=uuiFew1wM30)

When you leave Lambda Jam and return to work, do you expect to apply what you’ve learned here to hard problems, or is there just never time or permission to venture outside of fixing “undefined is not a function” in JavaScript? Many of us do use functional languages, machine learning, proof assistants, parsing, and formal methods in our day jobs, and employment by a CS research department is not a prerequisite. As a consultant who wants to choose the most effective tool for the job and keep my customers happy in the process, I’ve developed a structured approach to finding ways to use the tools of the future (plus a few from the 70s!) in the enterprises of today. I’ll share that with you and examine research into the use of formal methods in other companies. I hope you will leave the talk excited about your job!

### Your Flying Car is Ready: Amazing Programming Tools of the Future, Today!
* [CodeMash](http://www.codemash.org/)
· 8 January 2015
· [Slides](https://speakerdeck.com/craigstuntz/your-flying-car-is-ready-amazing-programming-tools-of-the-future-today)
* [Dog Food Conference](http://dogfoodcon.com/)
· 29 September 2014
· [Slides](https://speakerdeck.com/craigstuntz/your-flying-car-is-ready-amazing-programming-from-the-future-today)

What if simply writing "unit tests" was enough to produce a program which makes them pass? What if your compiler could guarantee that your OpenSSL replacement follows the TLS specification to the letter? What if you could write a test which showed that your code had no unintentional behavior?

Microsoft Research is well known for its contributions to Kinect, F#, the Entity Framework, WorldWide Telescope, and more, but it’s also the home of a number of programming tools which do things which many programmers would consider surprising, if not impossible. But they work, and in this session you’ll see them in action.

Like the idea of code contracts, but concerned about runtime performance and errors? The Dafny language can check contracts at compile time. Sounds a bit magical, but it works! I’ll use the Z3 theorem prover to generate working programs from specifications alone. Sound impractical? I’ll explain how it is used to make Hyper-V and Windows Azure secure. I’ll show the F7 specification language for F# and relate how its authors used it to not only produce a TLS implementation which probably follows the spec, but to also identify dangerous holes in the TLS specification itself. You’ll learn how Amazon uses the TLA+ specification language to prove that there are no edge cases in its internal protocols.

Far from being research toys, these tools are in daily use in cases where stability, security, and reliability of code matters most. Can they help with your hardest problems? You might be surprised!

### Cloud Security, For Real This Time: Homomorphic Encryption and the Future of Online Privacy
* [Franklin University Computing Sciences](http://einstein.franklin.edu/) / [Papers We Love Columbus](http://paperswelove.org/chapter/columbus/)
· 24 February 2015
· [Slides](https://speakerdeck.com/craigstuntz/cloud-security-for-real-this-time-homomorphic-encryption-and-the-future-of-data-privacy-1)
* [CloudDevelop](http://clouddevelop.org/)
· 17 October 2014
· [Slides](https://speakerdeck.com/craigstuntz/cloud-security-for-real-this-time-clouddevelop-2014)
* [OWASP Columbus](https://www.owasp.org/index.php/Columbus)
· 27 February 2014
· [Slides](https://speakerdeck.com/craigstuntz/cloud-security-for-real-this-time-homomorphic-encryption-and-the-future-of-data-privacy)
* Slashdot/Geeknet virtual trade show "Moving to Better Secure the Cloud"
· 15 February 2012

Online tax preparation or financial advice sounds like a viable business, but "secure" sites are broken every day. Consumers are rightly wary of disclosing their personal information to cloud-based service providers. How can you build a service which delivers real value and is backed by a hard, cryptographic guarantee of security?

What if it were possible for a customer to give their data to a cloud provider in encrypted form, and for that provider to perform useful computations on that data without ever decrypting it? The results would be delivered to the customer, encrypted with a key that only they knew. It sounds like an ideal solution, but maybe impossible?

This is the promise of homomorphic encryption. The idea has been around for some time, but it was considered intriguing but maybe not possible until Craig Gentry’s groundbreaking thesis. Gentry later published a much more accessible paper called "Computing Arbitrary Functions of Encrypted Data".

### Diagnosing Cancer with Azure Machine Learning
* [CloudDevelop](http://clouddevelop.org/) 2015
· 23 October 2015
· [Slides](https://speakerdeck.com/craigstuntz/machine-learning)
* [Stir Trek](http://stirtrek.com/)
· 1 May 2015
· [Slides](https://speakerdeck.com/craigstuntz/diagnosing-cancer-with-azure-machine-learning-1)
· [Video](https://www.youtube.com/watch?v=XPbiwxa2UfU)

Central Ohio Cloud Computing User Group ·10 November 2014 · Slides
Machine learning allows you to find solutions to problems which are not solvable by other means. Azure Machine Learning provides a mix of features designed to allow you to easily create "predictions as a service. This presentation is both an introduction to machine learning concepts for developers new to the field and an example of how to solve real problems with Azure ML. We will build an experiment to predict cancer diagnoses based on observed characteristics of diagnostic imaging. We will also compare what we have built with other systems which attempt to solve the same class of problems and give pointers for learning more.

### Dealing with Outside Pressure - Staying Scrum
* [Agile.Next](http://www.agiledotnext.com/)
· 24 October 2014
· [Slides](https://speakerdeck.com/craigstuntz/dealing-with-outside-pressure)

Along the Agile adoption journey, Scrum teams are faced with both internal and external obstacles to fully embracing Scrum and reaping the benefits. Internally, teams may compromise on the essential elements of Scrum, such as not holding a retrospective at the end of a sprint or holding stand-ups only when the entire team is present rather than on a daily basis. Collectively, these compromises are known as “ScrumButs” and are all too common and dilute the benefits that Scrum provides to software projects. These obstacles may also be applied externally, such as a requirement for a detailed project plan or “gate reviews” for the project to proceed to the next “phase.” Managing these obstacles to ensure that the benefits of Scrum are fully realized while understanding and managing the organizational culture are important to a successful adoption and maintaining continuous improvement.
