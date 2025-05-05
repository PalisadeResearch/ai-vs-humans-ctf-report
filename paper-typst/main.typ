#import "@preview/drafting:0.2.1": margin-note, set-page-properties

#set text(size: 10pt)


#let tododmv(body) = margin-note(stroke: blue)[#text(body, size: 7pt)]

#let todoap(body) = margin-note(stroke: red)[#text(body, size: 7pt)]

#align(center)[
  #text(17pt, [Evaluating AI cyber capabilities with crowdsoursed elicitation])

  #grid(columns: (1fr,) * 1, row-gutter: 24pt)[
    Artem Petrov, #footnote[Correspondence to #link("mailto:artem.petrov@palisaderesearch.org") CC: #link("mailto:ctf-event@palisaderesearch.org")]
    Dmitrii Volkov
  ] #tododmv[I think we should thank Reworr, Rustem, Alexander in Acknowledgements but not here] #todoap[Ok. I think it would be cool to have some policy to manage expectations here]

  2025-04-25
  
  = Abstract

  #block(width: 80%, [
    #align(left)[
      == v1
      AI capability evaluations often suffer from underelicitation. Evaluations of harmful capabilities, like cyber, exhibit this even more: frontier AI labs are not incentivized to put effort into proving their models dangerous, while safety organizations often lack the necessary resources to pit much effort into agent design. //DISCUSS

      Additionally, classic benchmarks often lack the intuition of how its score translates to the equivalent human expertise.

      To solve these issues we tried a crowdsoursing approach - we organized a Capture The Flag (CTF) event where AI developers and researchers competed against each other and human hackers. 6 AI teams joined in, one of which beat our best-effort approach.

      AIs ranked *top-13%* among teams that captured at least one flag, *while being as fast as top multi-person human teams*. AIs solved Crypto and Reversing challenges of the "medium" level. Our setup allows us to report first ever 50%-task-completion time horizon for cyber. It is on the order of 1 hour, which is consistent with METR's estimate #cite(<measuring-ai-ability-to-complete-long-tasks>) for general AI performance.

      We also examine AI performance on another CTF event - CyberApocalypse, where it achieves top-21% score.

      == v2
      We organized a first of a kind Capture The Flag (CTF) event where AI developers and researchers competed against each other and human hackers. 6 AI teams joined in, one of which beat our best-effort approach. This shows how crowdsourcing can help with underelicitation.
      
      AIs ranked *top-13%* among teams that captured at least one flag, *while being as fast as top multi-person human teams*. AIs solved Crypto and Reversing challenges of the "medium" level. Our setup allows us to report first ever 50%-task-completion time horizon for cyber #tododmv[I feel confused reading this]. It is on the order of 1 hour, which is consistent with METR's estimate #cite(<measuring-ai-ability-to-complete-long-tasks>) for general AI performance.

      We also examine AI performance on another CTF event - CyberApocalypse, where it achieves top-21% score.
    ]
  ])
]

#set heading(numbering: "1.")

= Introduction

Eliciting AI capabilities is hard. Yet accurately estimating AI capabilities is important, especially when it comes to dangerous capabilities, as it determines whether a model is safe to release.
//Regulators and frontier AI Labs need to know if the model has capabilities to inflict substantial damage in the hands of a motivated malicious actor.
// Tangent about why unsafe models are bad?
// 
//  Performance of an AI agent depends a lot on its harness.
// 
Cyber is one of such capabilities.

Cyber evaluations may be underelicited, as we discuss in @discussion.
// Allude to discussion?

// Crowdsourcing is a tool used to bring in external expertise. Prominent examples of crowd sourcing are Kaggle challenges and hackathons.

In this paper we explore crowdsourcing elicitation efforts as a strategy to boost cyber performance and close the evals gap #cite(<apollo-research-evals-gap>). To do that, we host a CTF competition, inviting AI developers to compete against humans and each other for a 7500\$ prize pool.

// TODO: add section about "what is ctf"
We also report on the performance AI exhibited in this event and compare it to human performance. Finally, we analyze AI performance on CyberApocalypse - a large CTF competition with thousands of participants.

= AI vs Humans CTF

In collaboration with Hack The Box we organized an "AI vs Humans CTF" event#footnote[AI vs Humans CTF event page: https://ctf.hackthebox.com/event/details/ai-vs-human-ctf-challenge-2000
].

In our pilot event we wanted to make it as easy as possible for the AI teams to compete. Hence, the event focused on Crypto and Reversing challenge categories because these categories were the easiest to build a harness for. They only require running commands in the terminal, without the need for dynamic interactions with external machine. 

== Absolute standings
// 152 human teams  +6 ai teams
Overall 403 teams registered for the event, of which only 158 solved at least 1 challenge - 152 human teams and 6 AI teams.

Palisade ran 2 agents during this event - our adaptation of Claude Code for CTFs and our in-house React&Plan agent design #cite(<turtayev2024hackingctfsplainagents>).

You can see the final AI teams standings in @ai_vs_hum_standings.

#figure(
  table(
    columns: 3,
    align: (left, center, center),
    [*Team*], 
    [*Challenges solved*], 
    [*Leaderboard rank* #footnote[In case of teams solving an equal number of challenges, the faster teams rank higher on the leaderboard]],
    ..csv("tables/ai_team_standings_AI_vs_Humans_CTF.csv").flatten().slice(3),
  ),
  caption: [AI teams standings #footnote[The full leaderboard, including human teams, is available at https://ctftime.org/event/2723]. Best AI team achieves top-13% performance among teams that solved at least 1 challenge.],
) <ai_vs_hum_standings>

// As this was our first challenge, we saturated ><

== Speed

One of the core advantages AIs hold over humans is speed.

If we look at @ai_vs_hum_progression, we can see how quickly teams solved the challenges. AI teams seem to be on par with top human teams in speed.

#figure(
  image("plots/team_progression_AI_vs_Humans_CTF_aligned.png", width: 100%),
  caption: "Number of challenges solved over time",
) <ai_vs_hum_progression> #tododmv[Do we need the median line?]#todoap[Two similar lines may paint a cleaner picture on first look than a bunch of different lines. Is that helpful?]

The incredible speed of top human teams surprised us, so we reached out to the 5 top human teams for a comment. They say they are able to crack CTFs so fast, because they are professional CTF players and know all the common techniques to solve them. One participant told us that he was "playing on a couple internationally-ranked teams with years of experience". 

// TODO: add appendix showcasing "average human team speed" to highlight the exceptionalism of the top teams


== Agent designs

// Should this be an appendix?

After the competition concluded, we reached out to AI teams for comments on their agent design.

Here are some of the agent designs used by AI teams:

*CAI*:

The best performing team. They have a custom harness design they spent about 500 dev-hours on. You can read about it in their paper. #cite(<mayoralvilches2025caiopenbugbountyready>)

*Palisade Claude Code*

We adapted Claude Code for solving CTFs by writing a simple initial prompt.

Our claude code ( + Imperturbable enigma + claude code) // TODO: add their solve rate to appendix

*imperturbable*

From the participant:

```
I spent 17 dev-hours on agent design

I used EnIGMA (with some modifications) and Claude Code, with different prompts for rev/crypto that I iteratively tweaked. Most prompt tweaks were about:
- preventing the model from trying to guess the flag based on semantics
- making sure the model actually carefully inspects the task before coming up with its strategy
- recommending particular tools that were easier for the LLM to use.

Here is the spreadsheet I used to track my progress

https://docs.google.com/spreadsheets/d/1sdMC2AFwZ131vNG-iHyiDL0j2nyqa3gV5fN234QkXxk/edit?usp=sharing
```

*Palisade React&Plan*

Our agent we designed while working on @turtayev2024hackingctfsplainagents


= Cyber Apocalypse

Cyber Apocalypse is an annual CTF competition, organized by Hack The Box. Two AI teams participated in this event. Overall, 3994 human teams #tododmv[count humans rather than teams]#todoap[what do you mean by that?] solved at least one challenge.

You can see the final AI standings in table @ca_standings.

Palisade's submissions performed poorly, because our harness was not designed to interact with external machines, while about 2/3 of challenges required it.

#let ca_results = csv("tables/ai_team_standings_CyberApocalypse.csv")

#figure(
  table(
    columns: 3,
    align: (left, center, center),
    [*Team*], 
    [*Challenges solved*], 
    [*Leaderboard rank*],
    ..ca_results.flatten().slice(3),
  ),
  caption: [AI teams standings for Cyber Apocalypse #footnote[The full leaderboard, including human teams, is available at https://ctftime.org/event/2674]. AI achieves top-21% performance among teams that solved at least one challenge.],
) <ca_standings>

#figure(
  image("plots/team_progression_CyberApocalypse_aligned.png", width: 100%),
  caption: "Number of challenges solved over time",
) <ca_progression>


= Ability to complete long tasks

Modern AIs are known to struggle with tasks that require staying coherent on long timescales. A study #cite(<measuring-ai-ability-to-complete-long-tasks>) has shown that modern AIs can complete tasks requiring up to 1 hour of human expert effort.

To estimate the human expert effort equivalent to current AI capabilities we follow #cite(<measuring-ai-ability-to-complete-long-tasks>) by measuring the 50%-task-completion time horizon. This is the time humans typically take to complete tasks that AI models can complete with 50% success rate.

Analyzing the data from CyberApocalypse we reach a similar picture - AI can solve challenges requiring \~1 hour of effort from a median participant. See @equivalent_human_effort[Appendix] for details.

#figure(
  image("plots/is_ai_solved_vs_median_human_time_regression_CyberApocalypse.png", width: 100%),
  caption: "",
) <average_solve_time> #tododmv[improve chart design]#todoap[is that good?]

//TODO: get a real difficulties visual/table and percentage solved by AI.


// Hack The Box determines challenge difficulty by how long it takes a median human to solve it. However, 
// You can see the relation between



= Discussion <discussion>

== Cyber may be underelicited

// (can be lucky, can be unlucky - > need a bounty market) ("cyber maybe  underelicited". history -> some examples, taking them into account, we think that bounty market is good)
Currently cyber evaluations of frontier models are usually done by a small internal evaluation team. #todoap[Are there external evaluations in any of fromtier labs? How much are you confident about this actually being true?]

Cyber evaluatoins made by a single team sometimes may be underelicited.

Here are some anecdotal evidence for this:
- Deepmind reported #cite(<phuongEvaluatingFrontierModels2024>) 30% (24/81) score on the Intercode-CTF cyber benchmark #cite(<yang2023language>), which is lower than its baseline of 40% (40/100). This may have happened because their models were weaker, or because of insufficient elicitation. // TODO: check if their paper mentions agent design
- Project Naptime #cite(<projectzeroProjectNaptimeEvaluating2024>) pointed out the elicitation deficiencies in Meta's CyberSecEval 2 #cite(<bhatt2024cyberseceval2widerangingcybersecurity>), bumping score from 0.05 to 1.0 on the "Buffer Overflow" tests and from 0.24 to 0.76 on the "Advanced Memory Corruption" tests. They achieve it by modifying the agent harness in simple ways (like, providing LLM with access to proper tools and WAY 2). // EXTRATODO
- Similarly, we managed to get SOTA on a Intercode-CTF by being careful with agent design #cite(<turtayev2024hackingctfsplainagents>), surpassing previously reported results. // This seems confusing for a 3rd party reader

We believe, crowdsourcing elicitation will increase evaluation robustness, because it reduces reliance on any specific team.

== Does crowdsourcing work?

To bootstrap the bounty, we focused on inviting 3 types of AI teams - AI red teaming/pentester startups, researchers that published papers on cyber agents design, and Frontier AI labs. 

Our hypothesis was that offensive AI startups would be interested to showcase their agent on the leaderboard, as it would be a good marketing to say "our agent beats x% of humans". This did not hold true - none agreed to participate, mostly ignoring our emails.
  
We theorize that could happen because startups we invited either have a specific customer and hence don't need to prove their product to the public; or have found a different way to prove their product, like getting a high rank on bug bounty programs. // TODO: rewrite

Several individuals and one offensive AI startup expressed interest to participate as an AI team without a targeted invitation from us. You can see the entire flow in @registration-flow.

#figure(
  table(
    columns: (auto, 2.2cm, 2.2cm, 3.2cm, 3.2cm),
    align: (left + horizon, center+ horizon, center+ horizon, center+ horizon, center+ horizon),
    [#align(center)[*AI team type*]], [*Invited by us*], [*Accepted the invite*], [*Expressed interest independently*], [*Participated in the event*], 
    [Offensive AI startups], [9], [0], [1], [1 (CAI)],
    [Researchers], [3], [1], [0], [1 (Cyagent)], // Cyagent team / Intercode team, Enigma team
    [Frontier Labs], [2], [1], [0], [1 (FCT)],
    [Individuals], [0], [0], [3], [2 (Imperturbable, Project S1ngularity)],
  ),
  caption: [AI teams registration flow for the AI vs Humans event],
) <registration-flow> #todoap[for max pretty this can be a sankey diagram]

CAI though did better than us.

// TODO: add elicitation efforts vs performance data for known teams

// Make a table of which team is which

// Be more polite:
// The frontier AI labs are not incentivized to prove their model dangerous, while small independent evaluators lack the necessary resources and expertise in agent harness design required to elicit the true level of capabilities.

= Conclusion

We want to have real time or better avaerness of AI cyber capabilities
// hard to trust a specific small team, as it is unreliable.
1. Policy-relevant grounding 
2. Cost-efficiency + robustness

Bounties solve these 2.

Call to action for grantmakers:
Moreover, CTFs are already happening - all we need is bounty money for AI track. If having an AI track that becomes popular default - no more grants needed.

Call to action for frontier labs:
Way better to know in realtime than to not know. Faster decision making for better safety.

Call to action for CTFs:
Consider AI track, for hype and attracting best experts (asks us for help - we have experience)

// Call to action for cyberProfessionals:
// Consider AI copilots  // Leave this as blank for dima

- AI achieved 1 hour time horizon on cyber (and having humans to measure this against is cool)
- Signs of crowdsourcing working, but results inconclusive
- AI outperformed our expectations based on initial evaluations. (saturated)

= Results:
- Elicitation bounty suggested (seems like a good idea) (we tried, you should too) (we think it can be cost effective) (handwave it. 20k per month vs US salary to discussion + make a handwave table) (DARPA does similar AIxCC challenge, but with different purpose)

- time horizon (Metr suggested for R&D, we did for Cyber)

- AI top-13% scores (now this is *grounded* -> hence legible for policymakers (competition with humans is more legible than benchmarks in general. Hence doing it this way is better for policymaker awareness)(more comprehensive than cybench?))


= Acknowledgements

We thank our Palisade Research colleagues: Reworr, who helped set up and run the Claude Code agent, achieving second place among AI teams; Rustem Turtayev, who helped set up the React&Plan agent; and Alexander Bondarenko, for experimenting with the Aider agent.

// I promised to include these for people who filled out the feedback form
We thank the AI teams who designed agents for this competition: CAI (Víctor Mayoral-Vilches, Endika Gil-Uriarte, Unai Ayucar-Carbajo, Luis Javier Navarrete-Lozano, María Sanz-Gómez, Lidia Salas Espejo, Martiño Crespo-Álvarez), Imperturbable (James Lucassen), FCT, Cyagent, and Project S1ngularity.

We are grateful to Hack The Box for providing challenges for the AI vs Humans CTF event, supporting us in organizing this event, and providing data for our analysis. This event would not happen without their help!

#bibliography("ref.bib", style: "chicago-author-date")

#pagebreak()

#set heading(numbering: none)

= Appendix

#set heading(numbering: "A.1")
#counter(heading).update(0)

= Measuring 50%-task-completion time horizon <equivalent_human_effort>

To estimate the human expert effort equivalent to current AI capabilities we follow #cite(<measuring-ai-ability-to-complete-long-tasks>) by measuring the 50%-task-completion time horizon. This is the time humans typically take to complete tasks that AI models can complete with 50% success rate.

Hack The Box estimates difficulty of the challenges by measuring how long it takes a median participant from first accessing the challenge data (by downloading challenge files or starting the docker container) to submitting a flag. We adopt this approach to measure human time spent solving a challenge.

When measuring "human expert performance" it is important to know whom we consider an expert. Since both events analyzed in this paper were open to the public, the expertise of participants varied from casuals to professional CTF players. 

We can measure the position of the human team on the leaderboard as a measure of its expertise. In @ca_time_horizon_detailed we show how the 50%-task-completion time horizon estimates change, depending on which percentage of top human teams we consider to be the experts. 



// TODO: [nit] Add info on how many flags were submitted without first accessing the files?

// TODO: discuss limitations (not considering time human has access to challenge description; not considering time humans sleep\eat for long challenges) and how we combat them

TODO


#figure(
  image("plots/is_ai_solved_vs_median_human_time_regression_CyberApocalypse_detailed.png"),
  caption: "50%-task-completion time horizon estimates we get, depending on which percentage of top human teams we consider experts for getting the human solve times. Data is from the Cyber Apocalypse event.",
) <ca_time_horizon_detailed>

// If have time, add the 50% time horizon vs n top teams plot.

// = Challenge difficulties

// #figure(
//   image("plots/challenge_solve_times_AI_vs_Humans_CTF.png"),
//   caption: "Human participants solve times distributions for challenges ",
//   placement: auto,
// )

// = Correcting for player number

// Naive multiplication is bad - it overestimates a lot. Pls do the correct way by calculating time to solve 
