---
title: "Presentation by D. Richard Hipp, \"SQLite: The World's Most Widely Used Database Engine\""
tags: SQLite, Richard Hipp
---

On 10 October 2017, I attended a presentation by D. Richard Hipp, called, "SQLite: The World's Most Widely Used Database 
Engine," and live-tweeted it. Twitter broke the thread in several distinct ways, so the following is a lightly edited 
version of my Twitter thread.

## SQLite

He pronounces it "ess queue ell ite," FWIW.

<img class="autowidth" src="/images/SQLite.jpg" alt="D. Richard Hipp with title slide for SQLite presentation." width="2048" height="1536" loading="lazy" />

"If you're not writing SQL statements which look like this, you're not doing it right."

<img class="autowidth" src="/images/SQLite-complicated-query.jpeg" "A fairly complex SQL statement with subqueries, function calls, and COALESCEs" width="2048" height="1536" loading="lazy">

By this, I think he meant: SQLite is a SQL DB engine, not a document DB. It has features such as JOINs, functions, and 
subqueries which you should use in your code.

## History and Impact

2000-05-29: "It's just a database. How hard can that be? I'll write my own." Posted it online, then got support calls 
from Motorola.

He thinks there are more than one trillion SQLite databases in use. More copies of the library than there are people on 
earth. There might be more copies of zlib, but not certain. Probably no other program is more common.

Why was SQLite successful? Single file library, open file format, backwards compatible back to 2004, reading data from 
SQLite is faster than reading individual files on filesystem.

## Team and Coding Practices

SQLite uses DO-178B development process for safety critical software. Tests analyze ASM to verify all branches taken in 
both directions.

Two people work full time on SQLite. "We change the code aggressively." He contrasts this with Postgres, which is stable 
due to low code churn (he says).

## Using It In Your Code

Which DB should I use? (Ed. note: Not Oracle.)

<img class="autowidth" src="/images/SQLite-storage-decision.jpeg" alt="SQLite storage decision checklist. Choose SQLite if you're not doing remote data, big data, concurrent writers, or gazillion transactions/sec." width="2048" height="1536" loading="lazy">

"90% of data storage problems don't have any of these constraints. Where people make mistakes is storing locally as 
JSON/XML." (Paraphrased)

<img class="autowidth" src="/images/SQLite-data-container.jpeg" alt="SQLite data container. 1. Gather data from the cloud. 2. Transmit SQLite database files to the device. 3. Use locally" width="2048" height="1536" loading="lazy">

## Future Plans

Next release of SQLite will use F2FS (if in use) for atomic writes, doubling write performance.

Using EXPLAIN keyword, you can see the bytecode for your query

<img class="autowidth" src="/images/SQLite-explain.jpeg" alt="EXPLAIN output for simple SQL query" width="2048" height="1536" loading="lazy">

"Because the query planner is an AI, we're never finished with it."

SQLite 4 will retire the B-tree storage engine and replace it with an LSM (log structured merge) storage engine engine.

Pros and cons of LSM:

<img class="autowidth" src="/images/SQLite-LSM.jpeg" alt="Pros and cons of LSM. Good: Faster writes, reduced write amplification, linear writes, less SSD wear. Bad: Slower reads, background merge process, more space on disk, greater complexity" width="2048" height="1536" loading="lazy">

Performance of LSM was bad enough that they abandoned SQLite 4 project. v5 will use some new, maybe NVRAM optimized 
storage, not sure which. As of 30 November 2020, the current production verion of SQLite was 
<a href="https://www.sqlite.org/releaselog/3_33_0.html">3.33.0</a>.

SQLite supports B-tree indices only in order to keep the library small

## He Doesn't Like Git

Things that are hard to compute in git because it uses key/value DAG instead of relations

<img class="autowidth" src="/images/SQLite-git-bad.jpeg" alt="Some things Git Does Not Compute Because Of Its Use Of Key/Value" width="2048" height="1536" loading="lazy">

SQLite sources are managed using <a href="https://www.fossil-scm.org/">Fossil</a>, a distributed version control system 
that was specifically designed and written to support SQLite development

## Q & A

On formal methods, "I'm interested in anything that will make the code better. Bring as many tools to the table as you 
can."

They're starting to use mutation testing. Not using formal verification per se at the moment.

(Ed. note: Fuzz testing has been a productive way to find bugs in SQLite and is now 
<a href="https://www.sqlite.org/testing.html">an official part of the SQLite test plan</a>.)

Any design regrets? "One of the most important things a project manager can do is to say no." Features added for clients 
he regrets: Shared cache and auto vacuum. "I have to support these through 2050!"

After the talk I asked him about his reaction to this John Regehr quote:

> "Unfortunately, C and C++ are mostly taught the old way, as if programming in them isn’t like walking in a minefield."

I wasn't taking notes at this point so I can't do justice to his answer but he said he knows John and has spoken w/ him, 
but never in person. He said they disagree about what to do about undefined behavior, although it sounded to me more 
like a disagreement on tactics than strategy.

I'd really enjoy hearing a panel with these two some day.