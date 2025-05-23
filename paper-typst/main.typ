#import "@preview/drafting:0.2.1": margin-note, set-page-properties

// #set text(size: 10pt)
#set page(numbering: "1")
#set text(font: "New Computer Modern", lang: "en")
#set heading(numbering: "1.1")

#show table.cell.where(y: 0): strong
#set table(
  stroke: (x, y) => if y == 0 {
    (bottom: 0.7pt + black)
  },
  align: (x, y) => (
    if x > 0 { right } else { left }
  ),
)

#show heading: it => [
  #if it.level == 1 {
    place.flush()
  }
  #it
]

#let tododmv(body) = margin-note(stroke: blue)[#text(body, size: 7pt)] // Comments made by Dmitrii
#let todoap(body) = margin-note(stroke: red)[#text(body, size: 7pt)] // Comments made by Artem
#let todomt(body) = margin-note(stroke: green)[#text(body, size: 7pt)] //Comments made by Malika


#align(center)[
  #text(2em)[
    Evaluating AI cyber capabilities\ with crowdsourced elicitation
  ]

  #v(-0.75em)
  #text(0.9em, `https://github.com/palisaderesearch/ai-vs-humans-ctf-report`)
  #v(0.25em)

  #grid(
    columns: (1fr, 1fr),
    [Artem Petrov#footnote[Correspondence to #link("mailto:artem.petrov@palisaderesearch.org", `artem.petrov@palisaderesearch.org`) CC #link("mailto:ctf-event@palisaderesearch.org", `ctf-event@palisaderesearch.org`)]],
    [Dmitrii Volkov],
  )

  May 25, 2025
]

#pad(
  x: 3em,
  top: 1em,
  bottom: 0.4em,
  [
    #align(center)[*Abstract*]
    #set par(justify: true)
    As AI systems become increasingly capable, understanding their offensive cyber potential is critical for informed governance and responsible deployment. However, it's hard to accurately bound their capabilities, and some prior evaluations dramatically underestimated them.

    The art of extracting maximum task-specific performance from AIs is called "AI elicitation", and today's safety organizations typically conduct it in-house. In this paper, we explore crowdsourcing elicitation efforts as an alternative to in-house elicitation work.

    We host open-access AI tracks at two Capture The Flag (CTF) competitions: _AI vs. Humans_ (400 teams) and _Cyber Apocalypse_ (8000 teams). The AI teams achieve outstanding performance at both events, ranking top-5% and top-10% respectively for a total of \$7500 in bounties.

    This impressive performance suggests that open-market elicitation may offer an effective complement to in-house elicitation. We propose elicitation bounties as a practical mechanism for maintaining timely, cost-effective situational awareness of emerging AI capabilities.

    Another advantage of open elicitations is the option to collect human performance data at scale. Applying METR's methodology #cite(<kwa2025measuringaiabilitycomplete>), we found that AI agents can reliably solve cyber challenges requiring one hour or less of effort from a median human CTF participant.
  ],
)

= Introduction

It is important to know if an AI model has capabilities to inflict substantial damage in the hands of a motivated malicious actor.

However, many prior capability evaluations were shown to have underestimated AIs (@related-work). Concretely, a study would claim low performance for a model, but follow-up work would _elicit_ much more. This may happen as knowledge on using the model effectively is accumulated, with added effort, or just by luck.

To mitigate these effects and reduce the "evals gap" #cite(<apollo-research-evals-gap>), we propose crowdsourcing elicitation efforts: letting different teams compete on getting maximum AI performance on a task.

// Crowdsourcing is a tool used to bring in external expertise. Prominent examples of crowd sourcing are Kaggle challenges and hackathons.

We explore this approach in the domain of offensive cyber capabilities. A classic way to test cyber skills is a Capture The Flag (CTF) competition. A CTF features challenges in areas such as cryptography, reverse engineering, and web exploitation. Each challenge hides a “flag”—a unique string—that must be found by identifying and exploiting system vulnerabilities.

We hosted two AI CTF tracks: _AI vs. Humans_ and _Cyber Apocalypse_, letting AI teams compete against each other and human teams. This paper reports the AI teams' performance in these events, and compares it to human performance.

//MT: shortly summarize the findings?
// TODO: add section about "what is ctf"  - can it go to the next session?

= Related work <related-work>

There are indications that the offensive cyber capabilities of frontier AI models might be underelicited.

For example, while Meta's CyberSecEval 2 #cite(<bhatt2024cyberseceval2widerangingcybersecurity>) originally reported 5% buffer overflow and 24% advanced memory corruption success rates, #cite(<projectzeroProjectNaptimeEvaluating2024>, form: "prose")'s _Project Naptime_ boosted performance to 100% and 76% respectively with straightforward agent modifications.

Similarly, while a popular cyber benchmark InterCode-CTF #cite(<yang2023language>) reported up to 40% AI success rates with GPT-4o, #cite(<turtayev2024hackingctfsplainagents>) achieved 92% in just 5 weeks of elicitation #footnote[While the paper's headline result is 95%, we cite the ablation using GPT-4o only.].

These examples point to a theme: sometimes modifying the agent harness can unlock new capabilities. To make evaluations robust and reduce the reliance on any single team’s assumptions, the field may benefit from crowdsourcing elicitation.

= _AI vs. Humans_ CTF

#figure(
  table(
    columns: 3,
    align: (left, center, center),
    [*Agent*],
    [*Challenges solved*],
    [*Leaderboard rank* #footnote[In case of teams solving an equal number of challenges, the faster teams rank higher on the leaderboard.]],
    ..csv("tables/ai_team_standings_AI_vs_Humans_CTF.csv").flatten().slice(3),
  ),
  caption: [AI agents standings for _AI vs. Humans_ #footnote[The full leaderboard, including human teams, is available at https://ctftime.org/event/2723.]],
  placement: auto,
) <ai_vs_hum_standings>


The first event in our series was the _AI vs. Humans_ CTF, organized in collaboration with Hack The Box on 14-16 March 2025 #footnote[https://ctf.hackthebox.com/event/details/ai-vs-human-ctf-challenge-2000
]. This event was the first to publicly pit fully autonomous AI agents against experienced human teams in real-time, offering 20 cybersecurity challenges over 48 hours. We offered a prize pool of 7500\$ to incentivize participation and effort.

For the pilot event, we wanted to make it as easy as possible for the AI teams to compete. To that end, we used cryptography and reverse engineering challenges which could be completed locally, without the need for dynamic interactions with external machines.

We calibrated the challenge difficulty based on preliminary evaluations of our React&Plan agent #cite(<turtayev2024hackingctfsplainagents>) on older Hack The Box-style tasks such that the AI could solve \~50% of tasks.

See @agent_designs[Appendix] for the submitted agents' designs. All event performance data is available at https://github.com/palisaderesearch/ai-vs-humans-ctf-report.

== Absolute standings

Overall 403 teams registered for the event, of which 158 solved at least 1 challenge: 152 human teams and 6 AI teams. The Palisade Research team ran 2 AI agents during this event: a Claude Code adapted CTFs and a React&Plan agent.

The AI teams significantly exceeded our initial expectations and quickly saturated the challenges. The best AI team achieved top-5% performance (top-13% among teams solving at least one challenge), and most AI teams outperformed most humans (@ai_vs_hum_progression_all). Four out of seven agents completed 19/20 challenges. This highlights the power of crowdsourcing.

== Speed

#figure(
  image("plots/team_progression_AI_vs_Humans_CTF_aligned_top7_ai_top151_human.svg", width: 100%),
  caption: [Challenges solved over time for all teams, _AI vs. Humans_ CTF],
  placement: top,
) <ai_vs_hum_progression_all>

#figure(
  image("plots/team_progression_AI_vs_Humans_CTF_aligned.svg", width: 100%),
  caption: [Challenges solved over time for top teams, _AI vs. Humans_ CTF],
  placement: top,
) <ai_vs_hum_progression>

One of the core advantages AIs typically hold over humans is speed. As shown in @ai_vs_hum_progression, AI teams performed on par with top multi-human teams.

We were impressed the humans could match AI speeds, and reached out to the human teams for comments. Participants attributed their ability to solve the challenges quickly to their extensive experience as professional CTF players, noting that they were familiar with the standard techniques commonly used to solve such problems. One participant, for example, said that he was "playing on a couple of internationally-ranked teams with years of experience".

// TODO: add appendix showcasing "average human team speed" to highlight the exceptionalism of the top teams

\
= _Cyber Apocalypse _

On 21–26 March 2025 we hosted an AI track at _Cyber Apocalypse_ #footnote[https://www.hackthebox.com/events/cyber-apocalypse-2025], an annual Hack The Box competition that attracts a large number of human participants and offers a diverse set of challenges. 8129 human teams (18369 players) registered for the event, and 3994 teams solved at least one challenge.

We invited the AI teams from the _AI vs. Humans_ CTF event to participate in this competition to evaluate their performance in a different environment. Ultimately, two AI teams took part, collectively deploying four AI agents. The best AI agent achieved top-10% performance (top-21% among teams solving at least one challenge, @ca_standings).

As this competition's challenges were not saturated by AI, the resulting data allowed us to calculate the 50%-completion-time horizon, discussed in the next section.

#let ca_results = csv("tables/ai_team_standings_CyberApocalypse.csv")

#figure(
  table(
    columns: 3,
    align: (left, center, center),
    [*Agent*], [*Challenges solved*], [*Leaderboard rank*],
    [CAI], [20 / 62], [859],
    [Palisade Claude Code #footnote[Palisade's submissions performed poorly because our harness was not designed to interact with external machines, while about 2/3 of challenges required it.]],
    [5 / 62],
    [2496],

    [Palisade Aider], [3 / 62], [2953],
    [Palisade React&Plan], [2 / 62], [3199],
  ),
  caption: [AI agents standings for _Cyber Apocalypse_ CTF #footnote[The full leaderboard, including human teams, is available at https://ctftime.org/event/2674]],
  placement: auto,
) <ca_standings>

#figure(
  image("plots/team_progression_CyberApocalypse_aligned.svg", width: 100%),
  caption: [Challenges solved over time for top teams, _Cyber Apocalypse_ CTF],
  placement: auto,
) <ca_progression>

= Ability to complete long tasks

Modern AIs are known to struggle with tasks that require staying coherent on long timescales. A recent study by METR has shown that modern AIs can reliably complete tasks requiring up to 1 hour of human expert effort in software engineering @kwa2025measuringaiabilitycomplete.

We measure METR's 50%-task-completion time horizon metric for offensive cyber tasks. This metric shows the time humans typically take to complete a task that AI models can complete in 50% of cases.

Using the _Cyber Apocalypse_ data, we find that AI can solve challenges requiring \~1 hour of effort from a median CTF participant (@average_solve_time). See @equivalent_human_effort[Appendix] for details.

#figure(
  image("plots/is_ai_solved_vs_median_human_time_regression_CyberApocalypse.svg", width: 100%),
  caption: [50%-task-completion time horizon, _Cyber Apocalypse_ (top 1% human teams)],
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

//CAI though did better than us. // not sure what this sentence is?

// TODO: add elicitation efforts vs performance data for known teams

// Make a table of which team is which

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

Accurately assessing the offensive capabilities of AI systems remains a major challenge for policymakers and researchers. Relying solely on evaluations conducted by a single team may be insufficient. To better understand the highly dynamic nature of AI capabilities, we need robust, open-market, real-time evaluations.

Toward this goal, we hosted a first-of-its-kind #footnote[The only other similar competition we know of was held as part of DARPA's AI Cyber Challenge (AIxCC), it had a different focus on advancing AI for cyber defense. See: https://aicyberchallenge.com] _AI vs. Humans _CTF competition, inviting AI developers to directly compete against each other and against human teams. We also analyzed AI performance in _Cyber Apocalypse_, a large CTF with thousands of participants.

Our results suggest that crowdsourcing elicitation is a promising approach to assessing AI capabilities: crowdsourced AI performance wildly exceeded our initial expectations, with AIs saturating the _AI vs. Humans_ CTF for a prize pool of only \$7500.

Hosting head-to-head competitions with human teams lets us report a more interpretable and policy-relevant signal than traditional benchmark scores. In _Cyber Apocalypse_, the best AI outperforms 90% humans, and solves tasks requiring up to one hour of human effort.

We suggest several ways in which crowdsourcing can offer value for different stakeholders:

- *For policy and R&D agencies*: Hundreds of CTFs are hosted yearly, providing a rich source of evaluation data. What is missing is targeted support for AI-focused tracks. Modest funding for prizes and coordination could establish a sustainable evaluation ecosystem. Once popularized, these tracks may require little or no ongoing funding.

- *For frontier AI labs*: Open-market evaluations offer a fast, low-cost way to uncover overlooked capabilities and validate internal evaluations.

- *For CTF Organizers*: Adding an AI track can increase visibility, attract participants, and introduce new research and media interest. Palisade is happy to assist with this.

As AI systems' capabilities grow, evaluation must keep pace. Evaluations should be clear enough to guide policy, and flexible enough to reveal what today's systems can actually do. We believe crowdsourced elicitation is a promising approach to this end.

#set heading(numbering: none)

= Acknowledgements

We thank our Palisade Research colleagues: Reworr, who helped set up and run the Claude Code agent, achieving second place among AI teams; Rustem Turtayev, who helped set up the React&Plan agent (which Artem had run); and Alexander Bondarenko, for experimenting with the Aider agent.

We thank Malika Toqmadi for help editing this manuscript.

We thank the AI teams who designed agents for this competition: CAI (Víctor Mayoral-Vilches, Endika Gil-Uriarte, Unai Ayucar-Carbajo, Luis Javier Navarrete-Lozano, María Sanz-Gómez, Lidia Salas Espejo, Martiño Crespo-Álvarez), Imperturbable (James Lucassen), FCT, Cyagent, and Project S1ngularity.

We are grateful to Hack The Box for providing challenges for the _AI vs Humans_ CTF event, supporting us in organizing this event, and providing data for our analysis. This event would not happen without their help!

= Authors' contributions

#table(
  columns: 5,
  align: (start, center, center, center, center),
  table.header([Name], [AP], [DV], [Others at Palisade], [Event participants]),
  [Original idea and methodology], [], [•], [], [],
  [Event organization], [•], [], [], [],
  [Running AI agents], [•], [], [•], [•],
  [Evaluation], [•], [], [], [],
  [Writing], [•], [•], [], [],
)

#bibliography("ref.bib", style: "chicago-author-date", title: "References")

#pagebreak()

#set heading(numbering: "A.1")
#counter(heading).update(0)

= Recruiting AI teams

#figure(
  table(
    columns: (auto, auto, auto, auto, auto),
    align: left,
    [#align(center)[*AI team type*]],
    [*Invited\ by us*],
    [*Accepted\ invite*],
    [*Independently\ reached out*],
    [*CTF\ team names*],

    [Offensive AI startups], [9], [0], [1], [CAI],
    [Researchers], [3], [1], [0], [Cyagent],
    [Frontier Labs], [2], [1], [0], [FCT],
    [Individuals], [0], [0], [3], [Imperturbable\ Project S1ngularity],
  ),
  caption: [AI teams registration flow for the AI vs Humans event],
) <registration-flow>

To bootstrap the bounty, we targeted three key groups of AI teams: startups specializing in AI red teaming and penetration testing, researchers who have published on cyber agent design, and frontier AI labs.

We expected that offensive AI startups would be interested to showcase their agents on the leaderboard, leveraging the marketing appeal of claiming “our agent outperforms X% of humans.” In practice, this assumption did not hold: none chose to participate, and most did not respond to our outreach.

We theorize that this lack of engagement may be due to the fact that the startups we contacted either serve specific customers and therefore have no need to publicly validate their products, or they rely on alternative forms of credibility — such as achieving high rankings in established bug bounty programs.

On the other hand, several individuals and one offensive AI startup expressed interest in participating as an AI team without receiving a targeted invitation from us. You can see the entire flow in @registration-flow.

= Submitted agent designs <agent_designs>

Below are some of the agent designs used by AI teams.

== CAI

Used a custom harness design they spent about 500 dev-hours on, see #cite(<mayoralvilches2025caiopenbugbountyready>).

== Imperturbable

From the participant:

#block(stroke: gray, inset: 5pt)[
  I spent 17 dev-hours on agent design

  I used EnIGMA (with some modifications) and Claude Code, with different prompts for rev/crypto that I iteratively tweaked. Most prompt tweaks were about:
  - preventing the model from trying to guess the flag based on semantics
  - making sure the model actually carefully inspects the task before coming up with its strategy
  - recommending particular tools that were easier for the LLM to use.
]

== Palisade Claude Code

We used an off-the-shelf Claude Code prompted for solving CTF challenges.

== Palisade React&Plan

See @turtayev2024hackingctfsplainagents.

= Measuring 50%-task-completion time horizon <equivalent_human_effort>

To estimate the human expert effort equivalent to current AI capabilities we follow #cite(<kwa2025measuringaiabilitycomplete>) by measuring the 50%-task-completion time horizon. This is the time humans typically take to complete tasks that AI models can complete with 50% success rate.

Hack The Box estimates difficulty of the challenges by measuring how long it takes a median participant from first accessing the challenge data (by downloading challenge files or starting the docker container) to submitting a flag. We adopt this approach to measure human time spent solving a challenge.

When measuring "human expert performance" it is important to know whom we consider an expert. Since both events analyzed in this paper were open to the public, the expertise of participants varied from casuals to professional CTF players.

We can measure the position of the human team on the leaderboard as a measure of its expertise. @ca_time_horizon_detailed shows how the 50%-task-completion time horizon estimates change depending on which percentile of the human teams we consider to be experts. The estimates maintain a similar order of magnitude.

// TODO: [nit] Add info on how many flags were submitted without first accessing the files?

// TODO: discuss limitations (not considering time human has access to challenge description; not considering time humans sleep\eat for long challenges) and how we combat them

#figure(
  image("plots/is_ai_solved_vs_median_human_time_regression_CyberApocalypse_detailed.svg"),
  caption: [50%-task-completion time horizon estimates, depending on which percentage of top human teams we consider experts for calculating the human solve times (_Cyber Apocalypse_)],
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
