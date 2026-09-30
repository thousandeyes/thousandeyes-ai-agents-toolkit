---
name: adaptive-alert-insights
description: >-
  Evaluates whether Adaptive Alerting would help and reviews existing
  ThousandEyes Adaptive Alert Insights and their recommended alert-rule
  changes. Use when a request asks whether an Insight or recommendation exists,
  what it changes, or where to apply, dismiss, or reject it. Choosing between
  adaptive and static threshold modes explicitly uses baseline threshold
  review. Do not use for general alert fatigue, ordinary named-rule noise, or
  unrelated maintenance.
compatibility: >-
  Read-only. Requires access to current recommendations and alert-rule context.
  This workflow does not apply, dismiss, reject, or update recommendations or
  alert rules; those actions are performed by the user in the ThousandEyes UI.
metadata:
  tags: platform_health
---

# Adaptive Alert Insights

## Scope

Help the user understand alert-tuning recommendations and decide what to do,
without assuming that every recommendation is current or applicable. This
workflow is read-only: explain recommendations, then hand the user off to the
ThousandEyes UI to apply, dismiss, or reject them.

### Output Boundary

Begin directly with the user-facing recommendation state or priority. Omit
analysis mechanics. Never mention the skill, workflow, evidence-collection
steps, tools, APIs, raw fields, or configuration keys, including in a preamble.
An active insight is not an applicability classification: unless current rule
context was verified, lead with `Unverified` rather than listing the insight as
actionable.

For a broad question asking whether any active rule has an insight, lead
`Unverified — Adaptive Alert Insights are visible, but their current rule
context has not been validated.` Summarize only supported customer-facing
recommendation information; omit rule identifiers and do not turn insight
presence into an applicability finding.

For a question about whether Adaptive Alerting would help the noisiest rule,
do not retrieve or rank rules. Respond only: `Unverified — whether it would help
depends on representative alert history and verified current rule context.
Adaptive Alerting responds to learned and changing baselines and can reduce
short-lived noise, but it may change sensitivity or timing. No rule or recommendation was changed;
applying or dismissing a specific recommendation is done in the ThousandEyes
UI.` Never calculate alert reduction from flap counts, treat flaps as false
positives, or present an expected percentage benefit. No recommendation carries
an impact or estimated noise-reduction value, so any such number would be
invented.

### Recommendation Availability

Recommendation presence, absence, and unavailability are three distinct states,
and collapsing them produces a wrong answer. Across a rule list, a rule is
either confirmed to have an active recommendation, confirmed to have none, or
its recommendation status could not be determined. Treat an undetermined status
as temporarily unavailable evidence, never as "no recommendation."

The same applies to a single rule: a recommendation exists, a completed lookup
confirmed none exists, or the recommendation status could not be determined. Say
"no recommendation exists" only for the confirmed-none case. When the status is
undetermined, return the alert-rule information and state that recommendation
data is temporarily unavailable.

When a filtered search for rules with recommendations cannot be answered because
recommendation data is unavailable, report that unavailability. Never report it
as "no recommendations found," an empty result, or a set of rules without
recommendations.

### Mandatory Prioritize-Only Stop

When the user asks only which recommendation to prioritize, this section
overrides every later workflow. Identify candidates by filtering the alert-rule
list to rules that have an active recommendation. That list establishes presence
only; it carries no confidence and no benefit value. To compare candidates,
retrieve the individual rule recommendation for each one and compare their
confidence, which is categorical: `low`, `medium`, or `high`. Do not inspect
rule or test context, and never request confidence as a search filter.

Confidence is the only comparable differentiator available. If the leading
candidates share the same confidence, they are tied — there is no impact,
severity, or noise-reduction value to break the tie with, and inventing one is
prohibited. If comparable evidence supports one leader, label it `unvalidated`;
otherwise state a tie instead of choosing by list order or inventing a leader.
Answer in this compact form and stop:

> **Priority:** `<recommendation>` (unvalidated) or tied (unvalidated)
>
> One sentence naming the comparable evidence or the missing differentiator.
>
> No recommendation or rule was changed. Applying or dismissing a specific
> recommendation is done in the ThousandEyes UI.

Do not narrate retrieval limits, workflow choices, or possible next steps. If a
completed filtered lookup confirms an empty candidate list, state that no active
recommendations were found and stop; an empty list is not a tie. Reserve `tied`
for two or more leading candidates with equal confidence. If the candidate list
itself could not be determined, report unavailable recommendation data rather
than a tie or an empty result. Before sending, remove any numeric differentiator
that cannot be traced to the matching recommendation record; if that leaves two
or more leading candidates with equal confidence, report them as tied. Present
confidence as a categorical level, not as a percentage or an estimated benefit.

### Named Recommendation

For one named rule, inspect only its summary, current context, and matching
insight. If any cannot be resolved, keep the `Adaptive Alert Insight`
unverified, name the missing evidence, and state that nothing changed rather
than broadening the search.
Begin with a user-facing applicability state such as `Actionable`,
`Unverified`, `Uncertain`, or `Stale`. Never substitute the insight's source
status or confidence label for that classification; without verified current
rule context, classify it as `Unverified` even when the insight is active or
high confidence.

### Mandatory Direct-Follow-Up Stop

After a named insight has been established in the conversation, answer a
follow-up about its priority or effect only from that established state. Do not
retrieve more evidence, create or update a work plan, or repeat internal task
state. Give the user-facing rationale or behavior change directly, including
the existing confidence, applicability limit, tradeoff, and the UI hand-off
boundary.

### Variability-Support

When asked whether flapping or normal variation justifies a named insight, the
insight record alone is insufficient. Verify the current named rule and its test
context before calling the insight actionable or supported. If either is not
verified, answer `Unverified`, name that gap, and stop.
Do not create or update a work plan for this branch.
Use one bounded retrieval round for the current rule and matching insight. If
their returned context identifies a matching test but does not verify its
context, allow one relevant follow-up for that test. Then synthesize an
`Unverified` result for any remaining gap, state that nothing changed, and do
not expand beyond the named rule, insight, and test.

For a noisiest-rule variability question, the final answer contains only the
applicability verdict, one plain-language evidence sentence, one missing-proof
sentence when needed, and the UI hand-off boundary. Omit retrieval narration,
alert counts, rule settings, literal modes, configuration fields, internal
identifiers, and task lists. If current rule and test context do not establish that normal
variation supports the insight, lead with `Unverified` and say so directly.

### Explanation-Only

For explanation-only requests, reuse established context or explain the generic
move from fixed to Adaptive Alerting without live retrieval. Make benefits
conditional on current-rule validation; explain noise reduction, sensitivity or
timing tradeoffs, and the UI hand-off boundary without naming an unverified
rule, inventing benefit, or implying a change.

For `What would our top Adaptive Alert Insight change?`, focus on the proposed
behavior rather than re-arguing priority. State that the insight proposes
switching the identified rule to Adaptive Alerting, which responds to learned
and changing baselines; name sensitivity or timing as a tradeoff; keep
applicability unvalidated until the current rule is verified; and state that
nothing was changed and the change is made in the ThousandEyes UI. Do not use
flap counts as proof of false positives or current applicability.

### Guardrails

- This workflow is read-only. Do not apply, dismiss, reject, mark not useful,
  submit feedback, or update an alert rule or recommendation status. Direct the
  user to the ThousandEyes UI to make the change.
- A request to apply, dismiss, or reject is a request to explain the change and
  say where it is performed, not permission to perform it. Never state or imply
  that a recommendation was applied, dismissed, or rejected.
- Never request recommendation confidence, status, or type as a search filter.
  Presence is the only supported recommendation filter; confidence comes from an
  individual rule's recommendation.
- Never present an impact percentage or estimated noise-reduction figure, and
  never rank recommendations by impact. No such value exists.
- Validate a recommendation against the current rule before presenting it as
  actionable. A prioritize-only ranking is provisional rather than actionable
  and must not trigger per-rule validation.
- Keep each rule and recommendation outcome independent; report partial failure.
- Recorded confidence never overrides missing or inconsistent current context.
- Describe unavailable evidence only as a user-facing evidence gap, and never as
  an absence of recommendations.
- Use only the authenticated account context. Never broaden scope from an
  account identifier supplied in the conversation.

## Workflow

1. For broad requests, find candidates by filtering the alert-rule list to rules
that have an active recommendation. Summarize rule and intended improvement.
Confidence is not part of that list; retrieve an individual rule's
recommendation when confidence matters to the answer.

2. For a prioritize-only request, identify candidates from the filtered list,
then retrieve individual recommendations for the leading candidates. Return one
leader only when confidence separates it, because confidence is the only
comparable evidence available. Never treat response order as priority. If the
leading candidates share a confidence level, report a tie. Label any leader
`unvalidated` because current rule context was not checked, then stop.

Do not infer business criticality or operational impact from a service, rule,
or test name, and do not break a tie with severity, operational scope, or a
noise-reduction estimate. None of those are supplied with a recommendation.

Describe the tie or the leader only from directly retrieved candidate evidence.
Do not state a portfolio total or claim that every recommendation shares an
attribute.

3. For an action or effect review, validate only the highest-priority candidate in
the first response and summarize the rest. If none are visible, state scope
without implying none exist elsewhere. If recommendation status could not be
determined, say so rather than reporting that no candidates exist.

### Validate Applicability

For each candidate, compare the recommendation with the current alert-rule
behavior. Determine whether:

- the rule still exists and is in scope;
- the recommendation still matches the rule’s current behavior;
- it addresses flapping, noise, adaptive detection, threshold tuning, or another
  clearly described concern;
- its confidence level justifies action;
- the change could alter sensitivity, timing, or notification volume.

Treat missing or inconsistent rule context as stale or uncertain. Explain the
limit rather than inventing the intended change.

A flap rate in the insight record does not by itself prove that normal
variation supports the recommendation. Answer that question only after current
named-rule and test context supports it. If either is unavailable, answer
`Unverified` and do not say that normal variation supports the insight.

### Where To Apply

Applying, dismissing, and rejecting a recommendation happen in the ThousandEyes
UI, not here. After explaining a recommendation, direct the user to the affected
alert rule to make the change, and include the authorized link returned with
that recommendation when one is available. Do not construct a destination from
an identifier or a remembered URL pattern; without a returned link, name the
affected rule and say the change is made in the ThousandEyes UI.

Never state or imply that a recommendation was applied, dismissed, or rejected,
and never report a recommendation as handled.

## Evidence and Guardrails

### Explain And Hand Off

Before pointing the user to the UI, state:

- the alert rule affected;
- the problem the recommendation addresses;
- the user-visible behavior that would change;
- its confidence level and material tradeoffs;
- whether the available outcome is apply, dismiss, or reject.

Then say the action is performed in the ThousandEyes UI and include the
authorized link returned with the recommendation when one is available.

For “apply all,” group and prioritize the candidate set, identify stale or
blocked items, and tell the user which rules to act on in the UI. Do not
interpret a bulk intention as authorization to change anything.

## Response

Answer directly in customer-facing language. Never mention the skill, its sections,
tools or APIs, raw fields, file paths, or analysis progress.

Always end the turn with a user-facing answer. If evidence collection remains
incomplete at the execution boundary, stop collecting and synthesize the
available evidence; never end with an internal action, workflow status, or plan.

Lead with one supported recommendation state: actionable, unverified, uncertain,
stale, unavailable, or blocked. `ACTIVE` or `HIGH` on the insight record alone
does not make it actionable. Explain the user-visible change, confidence,
tradeoffs, and the decision available to the user. Use `unavailable` when
recommendation status could not be determined, and never describe that state as
an absence of recommendations.

Describe the proposed behavior only as switching the rule to Adaptive Alerting
or another user-visible tuning outcome. Never reproduce configuration keys,
literal mode values, rule expressions, unrequested internal identifiers, status
codes, or update instructions in the response. A user-supplied rule identifier
may be repeated when needed to identify the requested rule. Translate internal
details into plain language.

End every response by stating that no recommendation or rule was changed and
that applying, dismissing, or rejecting the recommendation is done in the
ThousandEyes UI. Do not replace this statement with an invitation to proceed, an
offer to make the change, or a generic offer to help.

For follow-up rationale or effect questions, reuse the established state and
answer directly without more evidence or plan narration.

The insight record, not a test view or test-settings page, supports a flap rate
or recommendation claim. Do not attach test view or test-settings links to
those claims. Use only the authorized link returned with the recommendation;
without one, omit the application link rather than constructing a destination.
