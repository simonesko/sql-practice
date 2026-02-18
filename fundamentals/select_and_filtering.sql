/* =========================================================
CASE: Sales pipeline triage (weekly) — Growth/Sales oriented
Context:
- Table: deals
- Columns assumed:
  deal_id, company, stage, expected_close_date, amount, probability, owner, last_activity_at

Business question:
- Which open deals should we prioritize this week to maximize expected revenue and reduce slippage?

Definitions:
- Expected revenue = amount * probability
- Slippage = deals whose expected close date tends to slip (not closing on time);
  a practical proxy is "close date is near but the deal is cold" (no recent activity).

Logic:
1) Keep only open pipeline stages (exclude closed-won / closed-lost).
2) Focus on deals with expected close date within the next 7 days (includes overdue deals).
3) Rank by expected revenue (highest first).
4) Tie-breaker: prioritize colder deals first (older last_activity_at) to reduce slippage risk.

Output:
- deal_id, company, owner, stage, expected_close_date, amount, probability, expected_revenue, last_activity_at
========================================================= */

SELECT
  deal_id,
  company,
  owner,
  stage,
  expected_close_date,
  amount,
  probability,
  (amount * probability) AS expected_revenue,
  last_activity_at
FROM deals
WHERE stage IN ('Prospecting', 'Qualified', 'Proposal', 'Negotiation')
  AND expected_close_date <= (CURRENT_DATE + INTERVAL 7 DAY)
ORDER BY
  expected_revenue DESC,
  last_activity_at ASC
LIMIT 20;
;


/* =========================================================
CASE: Cash collection focus (working capital)
Context:
- Table: ar_invoices
- Columns assumed:
  invoice_id, customer, amount, due_date, status

Business question:
- Which overdue invoices should we chase first to reduce cash pressure?

Logic:
1) Keep invoices not fully paid.
2) Keep only overdue (due_date < today).
3) Rank by amount (largest impact first), then by due_date (oldest first).

Output:
- invoice_id, customer, amount, due_date, status
========================================================= */

SELECT
  invoice_id,
  customer,
  amount,
  due_date,
  status
FROM ar_invoices
WHERE status IN ('sent', 'overdue', 'partial')
  AND due_date < CURRENT_DATE
ORDER BY
  amount DESC,
  due_date ASC
LIMIT 30;

