#import "@preview/drafting:0.2.1": margin-note, set-page-properties

#set text(size: 10pt)

// Comments made by Dmitrii
#let tododmv(body) = margin-note(stroke: blue)[#text(body, size: 7pt)]

// Commnts made by Artem
#let todoap(body) = margin-note(stroke: red)[#text(body, size: 7pt)]

//Comments made by Malika
#let todomt(body) = margin-note(stroke: green)[#text(body, size: 7pt)]

#align(center)[]
  #text(17pt, [Evaluating AI cyber capabilities with crowdsoursed elicitation])

  #grid(columns: (1fr,) * 1, row-gutter: 24pt)[
    Artem Petrov, #footnote[Correspondence to #link("mailto:artem.petrov@palisaderesearch.org") CC: #link("mailto:ctf-event@palisaderesearch.org")]
    Dmitrii Volkov
  ] #tododmv[I think we should thank Reworr, Rustem, Alexander in Acknowledgements but not here] #todoap[Ok. I think it would be cool to have some policy to manage expectations here]

  2025-04-25
  
  = Abstract

  #block(width: 80%)
    #align(left)[
      == v1
      #strike[AI capability evaluations often suffer from underelicitation. Evaluations of harmful capabilities, like cyber, exhibit this even more: frontier AI labs are not incentivized to put effort into proving their models dangerous, while safety organizations often lack the necessary resources to pit much effort into agent design] #todoap[we must be gentler and more polite here and everywhere. + We are not sure about evals being underelicited for sure. We suspect it is that way, but nothing more.]

      Additionally, classic benchmarks often lack the intuition of how its score translates to the equivalent human expertise.

      To solve these issues we tried a crowdsoursing approach - we organized a Capture The Flag (CTF) event where AI developers and researchers competed against each other and human hackers. 6 AI teams joined in, one of which beat our best-effort approach.

      AIs ranked *top-13%* among teams that captured at least one flag, *while being as fast as top multi-person human teams*. AIs solved Crypto and Reversing challenges of the "medium" level. Our setup allows us to report first ever 50%-task-completion time horizon for cyber. It is on the order of 1 hour, which is consistent with METR's estimate #cite(<measuring-ai-ability-to-complete-long-tasks>) for general AI performance.

      We also examine AI performance on another CTF event - CyberApocalypse, where it achieves top-21% score.

      == v2
      We organized a first of a kind Capture The Flag (CTF) event where AI developers and researchers competed against each other and human hackers. 6 AI teams joined in, one of which beat our best-effort approach. This shows how crowdsourcing can help with underelicitation.
      
      AIs ranked *top-13%* among teams that captured at least one flag, *while being as fast as top multi-person human teams*. AIs solved Crypto and Reversing challenges of the "medium" level. Our setup allows us to report first ever 50%-task-completion time horizon for cyber #tododmv[I feel confused reading this]. It is on the order of 1 hour, which is consistent with METR's estimate #cite(<measuring-ai-ability-to-complete-long-tasks>) for general AI performance.

      We also examine AI performance on another CTF event - CyberApocalypse, where it achieves top-21% score.

      
      *v3 *

    ]  


#set heading(numbering: "1.")

= Introduction


Eliciting AI capabilities is hard. Yet accurately estimating them is important, especially when it comes to dangerous  capabilities, as it determines whether a model is safe to release. 
//Regulators and frontier AI Labs need to know if the model has capabilities to inflict substantial damage in the hands of a motivated malicious actor.
// Tangent about why unsafe models are bad?
// 
//  Performance of an AI agent depends a lot on its harness.
// 
#strike[Cyber is one of such capabilities.] We hypothesize that evaluations of offensive cyber capabilities may often be underelicited - that is, they may fail to fully reveal the system’s potential, as we discuss in @discussion.

// Allude to discussion?

// Crowdsourcing is a tool used to bring in external expertise. Prominent examples of crowd sourcing are Kaggle challenges and hackathons.

We propose crowdsourcing elicitation efforts as an effective strategy to boost cyber performance and close the evals gap#footnote[As defined by Apollo Research, the "evals gap" refers to the growing disparity between the increasing need for comprehensive safety evaluations of frontier AI models and the current insufficient availability of high-quality evaluations to identify the capabilities of existing and near-future models. See #cite(<apollo-research-evals-gap>) for more detailes.] #cite(<apollo-research-evals-gap>). To explore this novel approach, we hosted a first-of-a-kind "AI vs Humans" Capture The Flag (CTF) competition, inviting AI developers to compete against each other and human teams. We then additionally analyzed AI performance in CyberApocalypse - a large CTF competition with thousands of participants.  

In this paper, we report on the performance AI exhibited in these events and compare it to human performance.    

//MT: shortly summarize the findings? 
// TODO: add section about "what is ctf"  - can it go to the next session?



= AI vs Humans CTF

To explore crowdsourcing as an elicitation approach in practice, we organized "AI vs Humans CTF" competition. CTF competitions are cybersecurity events where both professionals and enthusiasts tackle challenges in areas such as cryptography, reverse engineering, and web exploitation. Each challenge hides a “flag” — a unique string — that must be found by identifying and exploiting system vulnerabilities. 

The event was organized in collaboration with Hack The Box in the period of 14-16 March 2025.#footnote[AI vs Humans CTF event page: https://ctf.hackthebox.com/event/details/ai-vs-human-ctf-challenge-2000 
] This event was the first to publicly pit fully autonomous AI agents against experienced human teams in real-time, tackling 20 cybersecurity challenges over 48 hours.#todomt[thought we need a sentence where we explain what was 'first-of-a-kind' about the CTF, correct me if this is not an accurate description]. We offered a monetary prize of 7500\$ to incentivize participation and effort. 

For the pilot event, we wanted to make it as easy as possible for the AI teams to compete. The event focused on challenges in the cryptography and reverse engineering, as these areas are the easiest to build a harness for. The challenges only required running commands in the terminal, without the need for dynamic interactions with external machine. 

== Absolute standings
// 152 human teams  +6 ai teams
Overall 403 teams registered for the event, of which only 158 solved at least 1 challenge - 152 human teams and 6 AI teams. 

Palisade ran 2 AI agents during this event - our adaptation of Claude Code for CTFs and our in-house React&Plan agent design #cite(<turtayev2024hackingctfsplainagents>). 

 Best AI team achieves top-13% performance among teams that solved at least 1 challenge#todomt[maybe a bit of discussion here on what does this result mean? what might be the implications?]. You can see the final AI teams standings in @ai_vs_hum_standings.

#figure(
  table(
    columns: 3,
    align: (left, center, center),
    [*Team*], 
    [*Challenges solved*], 
    [*Leaderboard rank* #footnote[In case of teams solving an equal number of challenges, the faster teams rank higher on the leaderboard]],
    ..csv("tables/ai_team_standings_AI_vs_Humans_CTF.csv").flatten().slice(3),
  ),
  caption: [AI teams standings.  #footnote[The full leaderboard, including human teams, is available at https://ctftime.org/event/2723]],
) <ai_vs_hum_standings>

// As this was our first challenge, we saturated ><

== Speed

One of the core advantages AIs typically hold over humans is speed. As shown in @ai_vs_hum_progression, AI teams performed on par with top human teams in both speed across almost all tasks.
// Todo: praise AI speed for reaching human performance
#figure(
  image("plots/team_progression_AI_vs_Humans_CTF_aligned.png", width: 100%),
  caption: "Number of challenges solved over time",
) <ai_vs_hum_progression> #tododmv[Do we need the median line?]#todoap[Two similar lines may paint a cleaner picture on first look than a bunch of different lines. Is that helpful?]

The exceptional speed of human teams surprised us, so we reached out to the 5 top human teams for comments. Participants attributed their ability to solve the challenges quickly to their extensive experience as professional CTF players, noting that they were familiar with the standard techniques commonly used to solve such problems. One participant, for example, said that he was "playing on a couple of internationally-ranked teams with years of experience". 


For details on AI agent designs, please see @agent_designs[Appendix]

// TODO: add appendix showcasing "average human team speed" to highlight the exceptionalism of the top teams


= Cyber Apocalypse  

On 21–26 March 2025, Hack The Box invited us to participate in another CTF event. Cyber Apocalypse is an annual competition that attracts a large number of human participants and proposes a diverse set of challenges#footnote[Cyber Apocalypse event page: https://www.hackthebox.com/events/cyber-apocalypse-2025]. 

Overall, 3994 human teams solved at least one challenge. We invited the AI teams from the "AI vs Humans CTF" event to participate in this competition to evaluate their performance under a different environment. Ultimately, two AI teams took part, collectively deploying four AI agents. AI teams achieved top-21% performance among teams that solved at least one challenge. You can see the final AI standings in @ca_standings. 

Palisade’s submissions performed poorly, because our harness was not designed to interact with external machines, while about 2/3 of challenges required it.

As this competition was less saturated with AI participation, the resulting data allowed us to calculate the 50%-completion-time horizon, discussed in the next session. 

#let ca_results = csv("tables/ai_team_standings_CyberApocalypse.csv")

#figure(
  table(
    columns: 3,
    align: (left, center, center),
    [*Agent*], 
    [*Challenges solved*], 
    [*Leaderboard rank*],
    ..ca_results.flatten().slice(3),
  ),
  caption: [AI agents standings for Cyber Apocalypse #footnote[The full leaderboard, including human teams, is available at https://ctftime.org/event/2674]. ],
) <ca_standings>

#figure(
  image("plots/team_progression_CyberApocalypse_aligned.png", width: 100%),
  caption: "Number of challenges solved over time",
) <ca_progression>



= Ability to complete long tasks #todomt[does this title reflect the aim of the research described in this section? maybe it should say something along the lines of 'human-centric measures of AI capabilities']
 
Modern AIs are known to struggle with tasks that require staying coherent on long timescales. A recent study by METR has shown that modern AIs can reliably complete tasks requiring up to 1 hour of human expert effort #cite(<measuring-ai-ability-to-complete-long-tasks>). 

To estimate the human expert effort equivalent to current AI capabilities, we follow METR #cite(<measuring-ai-ability-to-complete-long-tasks>) #todomt[better to quote the original paper as this is where the concept is explained https://arxiv.org/pdf/2503.14499] by measuring the 50%-task-completion time horizon. This is a metric that indicates the time humans typically take to complete tasks that AI models can complete with a 50% success rate.

Analyzing the data from CyberApocalypse we reach a similar outcome - AI can solve challenges requiring \~1 hour of effort from a median participant. See @equivalent_human_effort[Appendix] for details.

#figure(
  image("plots/is_ai_solved_vs_median_human_time_regression_CyberApocalypse.png", width: 100%),
  caption: "50%-task-completion time horizon calculation based on Cyber Apocalypse data",
) <average_solve_time> 

//TODO: get a real difficulties visual/table and percentage solved by AI.

// Hack The Box determines challenge difficulty by how long it takes a median human to solve it. However, 
// You can see the relation between 

//Alternative text: Measuring AI capabilities through human-centered metrics
//Understanding how AI performance compares to human expertise is essential for evaluating real-world readiness and informing policy. Traditional benchmarks can often be hard to interpret outside of technical domains and offer little insight into how scores relate to human expertise. 
//To this end, we adopted a metric proposed by METR (2025): the 50%-task-completion time horizon. This measure estimates the duration of tasks that AI models can complete with a 50% success rate and correlates it with the amount of time a human expert typically takes to complete those tasks. It offers a straightforward way to assess how "expert-like" an AI system is in practice. #todoap["I think this is not exact enough. See my original text."]
//Modern AIs are known to struggle with tasks that require staying coherent on long timescales. A recent study by METR has shown that modern AIs can reliably complete tasks requiring up to 1 hour of human expert effort #cite(<measuring-ai-ability-to-complete-long-tasks>). 
//We applied METR’s metric to the data from the CyberApocalypse competition. By analyzing task completion times among human participants and comparing them with AI agents’ performance, we found results consistent with METR’s original findings. Specifically, the AI agents were able to solve cyber challenges that required one hour or less of effort from a median human participant.
= Discussion <discussion> #todomt[have a crazy idea, what if we move section 5.1 to intro and section 5.2 to section 2 "AI vs Humans CTF". That way, we provide context to our main argument in the intro and discuss difficulties of recruiting without repetition of the argument of why "crowdsourcing is great" if we are to answer the questions I've posed re "does crowdsourcing work". Again, just a slightly crazy suggestion to consider:)]

== Cyber may be underelicited

// (can be lucky, can be unlucky - > need a bounty market) ("cyber maybe  underelicited". history -> some examples, taking them into account, we think that bounty market is good)
Typically, cyber evaluations of frontier models are done by a small internal evaluation teams within AI labs. #todoap[Are there external evaluations in any of frontier labs? How much are you confident about this actually being true?]

As a result, cyber evaluations made by small teams are often underelicited.

Here are some anecdotal evidence for this:
- Deepmind reported #cite(<phuongEvaluatingFrontierModels2024>) 30% (24/81) score on the Intercode-CTF cyber benchmark #cite(<yang2023language>), which is lower than its baseline of 40% (40/100). This may have happened because their models were weaker, or because of insufficient elicitation. // TODO: check if their paper mentions agent design
- Project Naptime #cite(<projectzeroProjectNaptimeEvaluating2024>) pointed out the elicitation deficiencies in Meta's CyberSecEval 2 #cite(<bhatt2024cyberseceval2widerangingcybersecurity>), bumping score from 0.05 to 1.0 on the "Buffer Overflow" tests and from 0.24 to 0.76 on the "Advanced Memory Corruption" tests. They achieve it by modifying the agent harness in simple ways (like, providing LLM with access to proper tools and WAY 2). // EXTRATODO
- Similarly, we managed to get SOTA on a Intercode-CTF by being careful with agent design #cite(<turtayev2024hackingctfsplainagents>), surpassing previously reported results. // This seems confusing for a 3rd party reader


We believe, crowdsourcing elicitation will increase evaluation robustness, because it reduces reliance on any specific team.

// Alternative text: Frontier AI models may be under-elicited in their offensive cyber capabilities. 
// Previous research, including our own, has shown that LLMs are better at cybersecurity problems than previously thought. In our recent study #cite(<turtayev2024hackingctfsplainagents>), using some straightforward prompting and agent design strategies, we were able to achieve state-of-the-art performance on a popular offensive security benchmark, InterCode-CTF, with a 95% success rate — surpassing previously reported results#todomt[citation missing? is it (Abramovich et al. 2024)?].
//This finding builds on a broader pattern of evidence suggesting that cyber evaluations often fail to fully activate the capabilities of advanced models. For instance, DeepMind’s report on the model’s hacking capabilities #cite(<phuongEvaluatingFrontierModels2024>) showed Gemini-1.0 solved 24 out of 81 InterCode-CTF tasks, which is lower than the benchmark's baseline of 40% (40/100)#cite(<yang2023language>). This may have happened because their models were weaker, or because of insufficient elicitation. 
//Earlier, Project Naptime#cite(<projectzeroProjectNaptimeEvaluating2024>) pointed out the elicitation deficiencies in Meta's CyberSecEval 2 #cite(<bhatt2024cyberseceval2widerangingcybersecurity>). By modifying the agent harness in relatively simple ways, the Project Naptime's team was able to boost the CyberSecEval 2 benchmark performance by up to 20x from Meta’s reported results - from 0.05 to 1.0 on the "Buffer Overflow" tests and from 0.24 to 0.76 on the "Advanced Memory Corruption" tests.
//These examples, including our own research, point to a consistent theme: minor changes in harness design can unlock significantly better performance than reported by frontier AI models' internal evaluation teams. To improve robustness and realism in AI cybersecurity evaluations, the field may benefit from crowdsourcing elicitation strategies, reducing reliance on any single team’s assumptions.
     

== Does crowdsourcing work?#todomt[this section only focuses on difficulties of recruiting/attracting AI teams to participate in crowdsourcing efforts. I think, it would be beneficial to also discuss whether crowdsourcing work as a method, explaining why we believe crowdsourcing might be a more efficient approach - answering the question in the section's title]

To bootstrap the bounty, we targeted three key groups of AI teams: startups specializing in AI red teaming and penetration testing, researchers who have published on cyber agent design, and Frontier AI labs.

We hypothesized that offensive AI startups would be interested to showcase their agents on the leaderboard, leveraging the marketing appeal of claiming “our agent outperforms X% of humans.” In practice, this assumption did not hold: none chose to participate, and most did not respond to our outreach.

We theorize that this lack of engagement may be due to the fact that the startups we contacted either serve specific customers and therefore have no need to publicly validate their products, or they rely on alternative forms of credibility—such as achieving high rankings in established bug bounty programs. // TODO: rewrite

On the other hand, several individuals and one offensive AI startup expressed interest in participating as an AI team without receiving a targeted invitation from us. #todomt[do we know what was their motivation? what would be a more effective strategy to recruit teams? Otherwise, it seems that the answer to the question of whether crowdsourcing works is "no"?]#todoap[Renaming this is fine]You can see the entire flow in @registration-flow.

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

CAI though did better than us. // not sure what this sentence is?

// TODO: add elicitation efforts vs performance data for known teams

// Make a table of which team is which

// Be more polite:
// The frontier AI labs are not incentivized to prove their model dangerous, while small independent evaluators lack the necessary resources and expertise in agent harness design required to elicit the true level of capabilities.

= Conclusion

We want to have real time or better awareness of AI cyber capabilities
// hard to trust a specific small team, as it is unreliable.
1. Policy-relevant grounding #todomt[not clear how]#todoap[By directly comparing against humans vs comparing against numbers on a benchmark]
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

* Our main Results:* 
- AI achieved 1 hour time horizon on cyber (and having humans to measure this against is cool)
- Signs of crowdsourcing working, but results inconclusive
- AI outperformed our expectations based on initial evaluations. (saturated) #todomt[we discussed that this might be moved somewhere to the body?]#todoap[feel free to add this to abstract, the initial expectations were based on the evals of our SOTA-achieving agent on old tasks from HTB before running the competition. The difficulty of challenges we selected was partially based on this initial evals]
- Elicitation bounty suggested (seems like a good idea) (we tried, you should too) (we think it can be cost effective) (handwave it. 20k per month vs US salary to discussion + make a handwave table) (DARPA does similar AIxCC challenge, but with different purpose #footnote[See https://aicyberchallenge.com])

- time horizon (Metr suggested for R&D, we did for Cyber)

- AI top-13% scores (now this is *grounded* -> hence legible for policymakers (competition with humans is more legible than benchmarks in general. Hence doing it this way is better for policymaker awareness)(more comprehensive than cybench?))

// Draft conclusion: 
//Accurately assessing the real-time offensive capabilities of AI systems remains a major challenge for policymakers and researchers. Relying on closed evaluations by small internal teams at frontier AI labs is insufficient — such assessments can lack transparency and are challenging for independent verification, making it difficult to build a shared understanding of current risks or make informed decisions about governance and safety. #todoap[we need to be more polite ]
//Our work explores crowdsourcing elicitation efforts as a practical and scalable alternative. By running AI agents alongside human participants in two Capture The Flag (CTF) competitions. We demonstrate that this approach can address two important needs: 
//1. Grounding AI capabilities in policy-relevant terms by benchmarking against human performance, rather than opaque technical metrics.
//2. Enabling scalable, cost-efficient evaluation than closed testing environments through open competitions and public challenges.
//

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

= Agent designs <agent_designs>

// Should this be an appendix? 
// MT: agree, we can add a note in the "Absolute standing" section referring to the Appendix for details on agent design 


Below are some of the agent designs used by AI teams.

*CAI*:

The best performing team. They have a custom harness design they spent about 500 dev-hours on. You can read about it in their paper. #cite(<mayoralvilches2025caiopenbugbountyready>)

*Palisade Claude Code*:

We adapted Claude Code for solving CTFs by writing a simple initial prompt.

Our claude code ( + Imperturbable enigma + claude code) // TODO: add their solve rate to appendix

*imperturbable*:

From the participant:

```
I spent 17 dev-hours on agent design

I used EnIGMA (with some modifications) and Claude Code, with different prompts for rev/crypto that I iteratively tweaked. Most prompt tweaks were about:
- preventing the model from trying to guess the flag based on semantics
- making sure the model actually carefully inspects the task before coming up with its strategy
- recommending particular tools that were easier for the LLM to use.

You can find the spreadsheet I used to track my progress here:

https://docs.google.com/spreadsheets/d/1sdMC2AFwZ131vNG-iHyiDL0j2nyqa3gV5fN234QkXxk/edit?usp=sharing
```

*Palisade React&Plan*:

The agent our team designed while working on @turtayev2024hackingctfsplainagents
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


= Challenges solved by AI per category and difficulty

