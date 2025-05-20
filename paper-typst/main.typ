#import "@preview/drafting:0.2.1": margin-note, set-page-properties

#set text(size: 10pt)
#set page(numbering: "1")
#show figure.where(
  kind: table
): set figure.caption(position: top)

// Comments made by Dmitrii
#let tododmv(body) = margin-note(stroke: blue)[#text(body, size: 7pt)]

// Commnts made by Artem
#let todoap(body) = margin-note(stroke: red)[#text(body, size: 7pt)]

//Comments made by Malika
#let todomt(body) = margin-note(stroke: green)[#text(body, size: 7pt)]

#text(17pt, [*Evaluating AI cyber capabilities with crowdsoursed elicitation*])


*Artem Petrov, #footnote[Correspondence to #link("mailto:artem.petrov@palisaderesearch.org") CC: #link("mailto:ctf-event@palisaderesearch.org")]
  Dmitrii Volkov*  #tododmv[I think we should thank Reworr, Rustem, Alexander in Acknowledgements but not here] #todoap[Ok. I think it would be cool to have some policy to manage expectations here] #h(1fr) 2025-04-25

#v(12pt)



//TODO: 
// - reference the repo with data. "we release all data and source code for this paper at this link: link"


// #block(width: 80%)
  // #align(left)
      // == v2
      // We organized a first of a kind Capture The Flag (CTF) event where AI developers and researchers competed against each other and human hackers. 6 AI teams joined in, one of which beat our best-effort approach. This shows how crowdsourcing can help with underelicitation.
      
      // AIs ranked *top-13%* among teams that captured at least one flag, *while being as fast as top multi-person human teams*. AIs solved Crypto and Reversing challenges of the "medium" level. Our setup allows us to report first ever 50%-task-completion time horizon for cyber #tododmv[I feel confused reading this]. It is on the order of 1 hour, which is consistent with METR's estimate #cite(<kwa2025measuringaiabilitycomplete>) for general AI performance.

      // We also examine AI performance on another CTF event - CyberApocalypse, where it achieves top-21% score.

      // *v3 *

  
As AI systems become increasingly capable, understanding their offensive cyber potential is critical for informed governance and responsible deployment. However, eliciting AI capabilities is hard. 

//Make more upfront that we are about evals gap
// In this paper, we explore Capture The Flag (CTF) competitions as a method for eliciting and evaluating offensive AI capabilities. We present findings from the first open _AI vs. Humans _CTF competition, where AI teams competed against each other and human hackers. To extend this evaluation, we also organized an AI track as part of _Cyber Apocalypse_, an annual CTF event with thousands of participants.

In this paper, we explore crowdsourcing elicitation efforts as an alternative to in-house elicitation work. We present findings from the first open _AI vs. Humans _CTF competition, where AI teams competed against each other and human hackers. To extend this evaluation, we also organized an AI track as part of _Cyber Apocalypse_, an annual CTF event with thousands of participants.

// AI systems outperformed our estimates grounded in prior research and current industry benchmarks for AI capabilities. 
Top AI teams effectively saturated our task set, completing 19 out of 20 challenges and ranking in the top 13% overall, while being as fast as best human teams. We further adapted METR's #cite(<kwa2025measuringaiabilitycomplete>) 50%-task-completion time horizon metric and found that AI agents perform as well on cyber tasks as on the general tasks: they can reliably solve challenges requiring one hour or less of effort from a median human participant.

While further work is needed to deepen our understanding, we tentatively suggest that CTFs may offer an effective and scalable alternative to lab-based elicitations. Evaluations, grounded in the performance of human participants, also promise a more intuitive and interpretable alternative to traditional benchmark scores, enhancing accessibility to both policymakers and the general public. 


#set heading(numbering: "1.")

= Introduction


Eliciting AI capabilities is hard. Yet accurately estimating them is important, especially when it comes to dangerous  capabilities, as it determines whether a model is safe to release. 
//Regulators and frontier AI Labs need to know if the model has capabilities to inflict substantial damage in the hands of a motivated malicious actor.
// Tangent about why unsafe models are bad?
// 
//  Performance of an AI agent depends a lot on its harness.
// 
 We hypothesize that evaluations of offensive cyber capabilities may often be underelicited - that is, they may fail to fully reveal the system’s potential, as we discuss in @discussion.

// Allude to discussion?

// Crowdsourcing is a tool used to bring in external expertise. Prominent examples of crowd sourcing are Kaggle challenges and hackathons.

We propose crowdsourcing elicitation efforts as a strategy to boost cyber performance and close the evals gap#footnote[As defined by Apollo Research, the 'evals gap' is the growing mismatch between the reliance on safety evaluations for policy decisions and the ability of existing evaluations to robustly identify capabilities of existing and near-future models. See #cite(<apollo-research-evals-gap>) for a more detailed discussion.] #cite(<apollo-research-evals-gap>). To explore this novel approach, we hosted a first-of-a-kind _AI vs. Humans _Capture The Flag (CTF) competition, inviting AI developers to compete against each other and human teams. We then additionally analyzed AI performance in _Cyber Apocalypse_ - a large CTF competition with thousands of participants.  

In this paper, we report on the performance AI exhibited in these events and compare it to human performance.    

//MT: shortly summarize the findings? 
// TODO: add section about "what is ctf"  - can it go to the next session?



= _AI vs. Humans_ CTF

To explore crowdsourcing as an elicitation approach in practice, we organized _AI vs. Humans_ CTF competition. CTF competitions are cybersecurity events where both professionals and enthusiasts tackle challenges in areas such as cryptography, reverse engineering, and web exploitation. Each challenge hides a “flag” — a unique string — that must be found by identifying and exploiting system vulnerabilities. 

The event was organized in collaboration with _Hack The Box_ in the period of 14-16 March 2025.#footnote[AI vs Humans CTF event page: https://ctf.hackthebox.com/event/details/ai-vs-human-ctf-challenge-2000 
] This event was the first to publicly pit fully autonomous AI agents against experienced human teams in real-time, tackling 20 cybersecurity challenges over 48 hours. We offered a monetary prize of 7500\$ to incentivize participation and effort. 

For the pilot event, we wanted to make it as easy as possible for the AI teams to compete. The event focused on challenges in the cryptography and reverse engineering, as these areas are the easiest to build a harness for. The challenges only required running commands in the terminal, without the need for dynamic interactions with external machines. 

== Absolute standings
Overall 403 teams registered for the event, of which only 158 solved at least 1 challenge - 152 human teams and 6 AI teams. 

_Palisade Research_ team ran 2 AI agents during this event - our adaptation of Claude Code for CTFs and our in-house React&Plan agent design #cite(<turtayev2024hackingctfsplainagents>). 
 
 Notably, AI teams significantly exceeded our initial expectations and the challenges were quickly saturated. Best AI team achieves top-13% performance among teams that solved at least 1 challenge. Four out of seven agents completed 19/20 challenges. You can see the final AI teams standings in @ai_vs_hum_standings. 
  
 Our expectations for AI performance had been based on preliminary evaluations of our React&Plan agent on older _Hack The Box_-style tasks.#todoap[D, are we allowed to say this?] The challenge difficulty was calibrated based on these prior results with expectations of AI solving \~50% of tasks. Turns out AI could do way better. This outcome suggests that conventional evaluation methods by small teams (like ours) may fail to fully surface the capabilities of current AI models, highlighting the need for more dynamic and diversified approaches.

#figure(
  table(
    columns: 3,
    align: (left, center, center),
    [*Agent*], 
    [*Challenges solved*], 
    [*Leaderboard rank* #footnote[In case of teams solving an equal number of challenges, the faster teams rank higher on the leaderboard.]],
    ..csv("tables/ai_team_standings_AI_vs_Humans_CTF.csv").flatten().slice(3),
  ),
  caption: [AI agents standings.  #footnote[The full leaderboard, including human teams, is available at https://ctftime.org/event/2723]],
) <ai_vs_hum_standings>

// As this was our first challenge, we saturated ><

== Speed

One of the core advantages AIs typically hold over humans is speed. As shown in @ai_vs_hum_progression, AI teams performed on par with top human teams in both speed across almost all tasks.
// Todo: praise AI speed for reaching human performance
#figure(
  image("plots/team_progression_AI_vs_Humans_CTF_aligned.svg", width: 100%),
  caption: [Number of challenges solved over time for _AI vs Humans_ CTF.#tododmv[Do we need the median line?]#todoap[Two similar lines may paint a cleaner picture on first look than a bunch of different lines. Is that helpful?]],
  placement: auto,
) <ai_vs_hum_progression> 

The exceptional speed of human teams surprised us, so we reached out to five top human teams for comments. Participants attributed their ability to solve the challenges quickly to their extensive experience as professional CTF players, noting that they were familiar with the standard techniques commonly used to solve such problems. One participant, for example, said that he was "playing on a couple of internationally-ranked teams with years of experience". 

For details on AI agent designs, please see @agent_designs[Appendix].

// TODO: add appendix showcasing "average human team speed" to highlight the exceptionalism of the top teams

You can see more plots in @detailed_data_appendix[Appendix].

We make all performance data available at TODO PUBLIC REPO LINK.

= _Cyber Apocalypse _ 

On 21–26 March 2025, _Hack The Box_ invited us to participate in another CTF event. _Cyber Apocalypse_ is an annual competition that attracts a large number of human participants and proposes a diverse set of challenges#footnote[_Cyber Apocalypse_ event page: https://www.hackthebox.com/events/cyber-apocalypse-2025]. 

Overall, 3994 human teams solved at least one challenge. We invited the AI teams from the _AI vs. Humans_ CTF event to participate in this competition to evaluate their performance in a different environment. Ultimately, two AI teams took part, collectively deploying four AI agents. AI teams achieved top-21% performance among teams that solved at least one challenge. You can see the final AI standings in @ca_standings. 

_Palisade’s_ submissions performed poorly, because our harness was not designed to interact with external machines, while about 2/3 of challenges required it.

As this competition challenges were not saturated by AI, the resulting data allowed us to calculate the 50%-completion-time horizon, discussed in the next section. 

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
  image("plots/team_progression_CyberApocalypse_aligned.svg", width: 100%),
  caption: [Number of challenges solved over time for _Cyber Apocalypse_ CTF.],
  placement: auto,
) <ca_progression>



= Ability to complete long tasks
 
Modern AIs are known to struggle with tasks that require staying coherent on long timescales. A recent study by _METR_ has shown that modern AIs can reliably complete tasks requiring up to 1 hour of human expert effort #cite(<kwa2025measuringaiabilitycomplete>). 

To estimate the human expert effort equivalent to current AI capabilities, we follow #cite(<kwa2025measuringaiabilitycomplete>) by measuring the 50%-task-completion time horizon. This is a metric that indicates the time humans typically take to complete tasks that AI models can complete with a 50% success rate.

Analyzing the data from _Cyber Apocalypse_ we reach a similar outcome - AI can solve challenges requiring \~1 hour of effort from a median participant. See @equivalent_human_effort[Appendix] for details.

#figure(
  image("plots/is_ai_solved_vs_median_human_time_regression_CyberApocalypse.svg", width: 100%),
  caption: [50%-task-completion time horizon calculation based on _Cyber Apocalypse_ data.],
  placement: auto,
) <average_solve_time> 

//TODO: get a real difficulties visual/table and percentage solved by AI.

// Hack The Box determines challenge difficulty by how long it takes a median human to solve it. However, 
// You can see the relation between 

//Alternative text: Measuring AI capabilities through human-centered metrics
//Understanding how AI performance compares to human expertise is essential for evaluating real-world readiness and informing policy. Traditional benchmarks can often be hard to interpret outside of technical domains and offer little insight into how scores relate to human expertise. 
//To this end, we adopted a metric proposed by _METR_ (2025): the 50%-task-completion time horizon. This is a metric that indicates the time humans typically take to complete tasks that AI models can complete with a 50% success rate. It offers a straightforward way to assess how "expert-like" an AI system is in practice.
//Modern AIs are known to struggle with tasks that require staying coherent on long timescales. A recent study by _METR_ has shown that modern AIs can reliably complete tasks requiring up to 1 hour of human expert effort #cite(<kwa2025measuringaiabilitycomplete>). 
//We applied _METR’s_ metric to the data from the _Cyber Apocalypse_ competition. By analyzing task completion times among human participants and comparing them with AI agents’ performance, we found results consistent with _METR’s_ original findings. Specifically, the AI agents were able to solve cyber challenges that required one hour or less of effort from a median human participant.
= Discussion <discussion> 

== Cyber may be underelicited

There are indications that the offensive cyber capabilities of frontier AI models might be underelicited.

Previous research, including our own, has shown that LLMs are better at cybersecurity problems than previously thought. In our recent study #cite(<turtayev2024hackingctfsplainagents>), using some straightforward prompting and agent design strategies, we were able to achieve state-of-the-art performance on a popular offensive security benchmark, _InterCode-CTF_, with a 95% success rate — surpassing previously reported results#todomt[citation missing? is it (Abramovich et al. 2024)?].

This finding builds on a broader pattern of evidence suggesting that cyber evaluations often fail to fully activate the capabilities of advanced models. For instance, _DeepMind’s_ report on the model’s hacking capabilities #cite(<phuongEvaluatingFrontierModels2024>) showed _Gemini-1.0_ solved 24 out of 81 _InterCode-CTF_ tasks, which is lower than the benchmark's baseline of 40% #cite(<yang2023language>). This may have happened because their models were weaker, or because of insufficient elicitation. 

_Project Naptime_ #cite(<projectzeroProjectNaptimeEvaluating2024>) pointed out the elicitation deficiencies in _Meta's_ _CyberSecEval 2_ #cite(<bhatt2024cyberseceval2widerangingcybersecurity>). By modifying the agent harness in relatively simple ways, the _Project Naptime's_ team was able to boost the _CyberSecEval 2_ benchmark performance by up to 20x from _Meta’s_ reported results - from 0.05 to 1.0 on the "Buffer Overflow" tests and from 0.24 to 0.76 on the "Advanced Memory Corruption" tests.

These examples, including our own research, point to a consistent theme: minor changes in harness design can unlock significantly better performance than reported by frontier AI models' internal evaluation teams. To improve robustness and realism in AI cybersecurity evaluations, the field may benefit from crowdsourcing elicitation strategies, reducing reliance on any single team’s assumptions.
     

== Challenges of recruiting AI teams 
#todomt[this section only focuses on difficulties of recruiting/attracting AI teams to participate in crowdsourcing efforts. I think, it would be beneficial to also discuss whether crowdsourcing work as a method, explaining why we believe crowdsourcing might be a more efficient approach - answering the question in the section's title]

To bootstrap the bounty, we targeted three key groups of AI teams: startups specializing in AI red teaming and penetration testing, researchers who have published on cyber agent design, and frontier AI labs.

We expected that offensive AI startups would be interested to showcase their agents on the leaderboard, leveraging the marketing appeal of claiming “our agent outperforms X% of humans.” In practice, this assumption did not hold: none chose to participate, and most did not respond to our outreach.

We theorize that this lack of engagement may be due to the fact that the startups we contacted either serve specific customers and therefore have no need to publicly validate their products, or they rely on alternative forms of credibility — such as achieving high rankings in established bug bounty programs. // TODO: rewrite

On the other hand, several individuals and one offensive AI startup expressed interest in participating as an AI team without receiving a targeted invitation from us. You can see the entire flow in @registration-flow.

This was our first attempt at crowdsourcing in this context, and while it offered valuable insights, we recognize the need for further experimentation — potentially including a higher bounty to better incentivize participation. 



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
  caption: [AI teams registration flow for the AI vs Humans event. #todoap[for max pretty this can be a sankey diagram]],
) <registration-flow> 

//CAI though did better than us. // not sure what this sentence is?

// TODO: add elicitation efforts vs performance data for known teams

// Make a table of which team is which

// Be more polite:
// The frontier AI labs are not incentivized to prove their model dangerous, while small independent evaluators lack the necessary resources and expertise in agent harness design required to elicit the true level of capabilities.

= Conclusion

// We want to have real time or better awareness of AI cyber capabilities
// // hard to trust a specific small team, as it is unreliable.
// 1. Policy-relevant grounding #todomt[not clear how]#todoap[By directly comparing against humans vs comparing against numbers on a benchmark]
// 2. Cost-efficiency + robustness

// Bounties solve these 2.

// Call to action for grantmakers:
// Moreover, CTFs are already happening - all we need is bounty money for AI track. If having an AI track that becomes popular default - no more grants needed.

// Call to action for frontier labs:
// Way better to know in realtime than to not know. Faster decision making for better safety.

// Call to action for CTFs:
// Consider AI track, for hype and attracting best experts (asks us for help - we have experience)

// // Call to action for cyberProfessionals:
// // Consider AI copilots  // Leave this as blank for dima

// * Our main Results:* 
// - AI achieved 1 hour time horizon on cyber (and having humans to measure this against is cool)
// - Signs of crowdsourcing working, but results inconclusive
// - AI outperformed our expectations based on initial evaluations. (saturated) #todomt[we discussed that this might be moved somewhere to the body?]#todoap[feel free to add this to abstract, the initial expectations were based on the evals of our SOTA-achieving agent on old tasks from HTB before running the competition. The difficulty of challenges we selected was partially based on this initial evals]
// - Elicitation bounty suggested (seems like a good idea) (we tried, you should too) (we think it can be cost effective) (handwave it. 20k per month vs US salary to discussion + make a handwave table) (DARPA does similar AIxCC challenge, but with different purpose #footnote[See https://aicyberchallenge.com])

// - time horizon (Metr suggested for R&D, we did for Cyber)

// - AI top-13% scores (now this is *grounded* -> hence legible for policymakers (competition with humans is more legible than benchmarks in general. Hence doing it this way is better for policymaker awareness)(more comprehensive than cybench?))

Accurately assessing the offensive capabilities of AI systems remains a major challenge for policymakers and researchers. Relying solely on evaluations conducted by internal teams at frontier AI labs is insufficient. To better understand the highly dynamic nature of AI capabilities, we need a more diverse and robust evaluation approach grounded in real-world, real-time testing.
Toward this goal, we hosted a first-of-its-kind _AI vs. Humans _CTF competition #footnote[The only other similar competition we know of was held as part of DARPA’s AI Cyber Challenge (AIxCC), it had a different focus on advancing AI for cyber defense. See: https://aicyberchallenge.com], inviting AI developers to directly compete against each other and against human teams. We also analyzed AI performance in CyberApocalypse, a large CTF with thousands of participants.

While our results are still preliminary, our initial experiments suggest that using CTF competitions to elicit offensive AI capabilities holds significant promise in several directions. 

Firstly, the crowdsourcing approach demonstrated potential for surfacing meaningful behaviors in AI systems in practical settings, exceeding our initial expectations of AI capabilities. In the _AI vs. Humans_ CTF competition, our top-performing AI team ranked in the top 13% of all participants, with several AI teams solving 19 out of 20 challenges — effectively saturating the task set. This outcome not only highlights current system capabilities but also demonstrates the value #todoap[what is this value?]of evaluating AI in direct competition with humans. However, further data and repeated trials are needed to fully assess its reliability and generalizability. 

To further ground AI performance relative to human capabilities, we adopted the 50%-task-completion time horizon metric proposed by _METR_ (2025). We found that AI agents were able to solve cyber tasks requiring up to one hour of effort from a median human CTF participant. This measure, adapted here for evaluating offensive capabilities, provides a more interpretable and policy-relevant signal than aggregate benchmark scores.

Moreover, we suggest that CTFs for AI elicitation is both cost-effective and practical, particularly for organizations operating with limited resources. We believe this mechanism can be easily replicated and scaled across future evaluations.

Our findings suggest several ways in which crowdsourcing can offer practical value for different stakeholders: 
- *For cybersecurity professionals:* *DIMA TODO*

- *For policy and R&D agencies*: CTFs already provide the infrastructure — what is missing is targeted support for AI-focused tracks. Modest funding for prizes and coordination could establish a sustainable evaluation ecosystem. Once popularized, these tracks may require little or no ongoing funding. 

- *For frontier AI labs*: Public evaluations offer a fast, low-cost way to uncover overlooked capabilities and validate internal assessments. Engaging in open competitions can improve safety decision-making by revealing how systems behave under diverse, adversarial conditions.

- *For CTF Organizers*: Adding an AI track can increase visibility, attract high-caliber participants, and introduce new research and media interest. Our team has experience supporting these efforts and is available to assist with design and execution. 

As AI systems grow in complexity, evaluation must keep pace. Moreover, evaluation methods should be clear enough to guide policy, and flexible enough to reveal what today’s systems can actually do.  This research is our initial contribution toward that goal.


= Acknowledgements

We thank our _Palisade Research_ colleagues: Reworr, who helped set up and run the Claude Code agent, achieving second place among AI teams; Rustem Turtayev, who helped set up the React&Plan agent; and Alexander Bondarenko, for experimenting with the Aider agent.

// I promised to include these for people who filled out the feedback form
We thank the AI teams who designed agents for this competition: CAI (Víctor Mayoral-Vilches, Endika Gil-Uriarte, Unai Ayucar-Carbajo, Luis Javier Navarrete-Lozano, María Sanz-Gómez, Lidia Salas Espejo, Martiño Crespo-Álvarez), Imperturbable (James Lucassen), FCT, Cyagent, and Project S1ngularity.

We are grateful to _Hack The Box_ for providing challenges for the _AI vs Humans_ CTF event, supporting us in organizing this event, and providing data for our analysis. This event would not happen without their help!

#bibliography("ref.bib", style: "chicago-author-date", title:"References")

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

To estimate the human expert effort equivalent to current AI capabilities we follow #cite(<kwa2025measuringaiabilitycomplete>) by measuring the 50%-task-completion time horizon. This is the time humans typically take to complete tasks that AI models can complete with 50% success rate.

_Hack The Box_ estimates difficulty of the challenges by measuring how long it takes a median participant from first accessing the challenge data (by downloading challenge files or starting the docker container) to submitting a flag. We adopt this approach to measure human time spent solving a challenge.

When measuring "human expert performance" it is important to know whom we consider an expert. Since both events analyzed in this paper were open to the public, the expertise of participants varied from casuals to professional CTF players. 

We can measure the position of the human team on the leaderboard as a measure of its expertise. In @ca_time_horizon_detailed we show how the 50%-task-completion time horizon estimates change, depending on which percentage of top human teams we consider to be the experts. 



// TODO: [nit] Add info on how many flags were submitted without first accessing the files?

// TODO: discuss limitations (not considering time human has access to challenge description; not considering time humans sleep\eat for long challenges) and how we combat them

TODO


#figure(
  image("plots/is_ai_solved_vs_median_human_time_regression_CyberApocalypse_detailed.svg"),
  caption: "50%-task-completion time horizon estimates we get, depending on which percentage of top human teams we consider experts for getting the human solve times. Data is from the _Cyber Apocalypse_ event.",
) <ca_time_horizon_detailed>

// If have time, add the 50% time horizon vs n top teams plot.

// = Challenge difficulties

// #figure(
//   image("plots/challenge_solve_times_AI_vs_Humans_CTF.svg"),
//   caption: "Human participants solve times distributions for challenges ",
//   placement: auto,
// )

// = Correcting for player number

// Naive multiplication is bad - it overestimates a lot. Pls do the correct way by calculating time to solve 

= Detailed data <detailed_data_appendix>

== Challenges solved by AI per category and difficulty

TODO or drop

== Top team scores in real time

#figure(
  image("plots/team_progression_AI_vs_Humans_CTF_unaligned.svg", width: 100%),
  caption: [Number of challenges solved over time for _AI vs Humans_ CTF.],
) <ai_vs_hum_progression_real_time>

== All teams trajectories for _AI vs Humans_ CTF 
#figure(
  image("plots/team_progression_AI_vs_Humans_CTF_aligned_top7_ai_top151_human.svg", width: 100%),
  caption: [Number of challenges solved over time fror all teams for _AI vs Humans_ CTF. Top AI Agents outperform almostall human teams.],
) <ai_vs_hum_progression_real_time>