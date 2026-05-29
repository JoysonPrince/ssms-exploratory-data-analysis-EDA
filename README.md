# 🔍 Exploratory Data Analysis — Sales & Customer Intelligence
> A structured SQL-based EDA project uncovering patterns in sales transactions, customer behavior, and product performance across a multi-table relational database.

---

## 📌 Project Overview

This project walks through a complete Exploratory Data Analysis (EDA) pipeline using SQL on a sales database. The goal was to move from raw table inspection all the way to ranked business insights — asking the right questions at each layer of the data before jumping to conclusions.

The analysis is structured in **6 progressive phases**, each building on the last.

---

## 🗂️ Dataset Structure

The database follows a **star schema** with the following key tables:

--> These are the same tables or the same star schema following my earlier **Data warehouse project** 

| Table | Type | Description |
|---|---|---|
| `gold.fact_sales` | Fact | Core transactional data — orders, amounts, quantities |
| `gold.dim_customers` | Dimension | Customer demographics — name, gender, country |
| `gold.dim_products` | Dimension | Product info — name, category, sub-category, cost |

---

## 🧭 Analysis Phases

### Phase 1 — Database Exploration
> *"Before asking questions, understand the landscape."*

- Identified all tables and their relationships
- Mapped schema structure and key columns
- Distinguished between **dimensions** (descriptive attributes — who, what, where) and **measures** (quantifiable values — revenue, quantity, orders)

---

### Phase 2 — Dimension Exploration
> *"What does the data describe?"*

- Explored all **countries** customers originate from
- Identified all **product categories** (major divisions) present in the catalog

---

### Phase 3 — Date Exploration
> *"When does the data live?"*

- Found the **first and last order dates** to establish the data timeline
- Calculated **how many years of sales history** are available
- Identified the **youngest and oldest customers** by birth date

---

### Phase 4 — Measure Exploration & Business Summary
> *"What are the headline numbers?"*

Core metrics computed:

| Metric | Description |
|---|---|
| Total Sales Revenue | Sum of all sales amounts |
| Total Items Sold | Sum of quantities across all orders |
| Average Selling Price | Mean transaction value |
| Total Orders | Count of distinct order numbers |
| Total Products | Count of unique products |
| Total Customers | Count of all registered customers |
| Active Customers | Customers who have placed at least one order |

📋 A **consolidated business overview report** was built using `UNION ALL` — combining all major KPIs into a single executive-style summary.

---

### Phase 5 — Magnitude Analysis
> *"How are things distributed?"*

Explored how key metrics break down across dimensions:

- 👥 Total customers by **country** and **gender**
- 📦 Total products by **category**
- 💰 Average cost per **product category**
- 📈 Total revenue by **category** and by **individual customer**
- 🌍 Distribution of sold items across **countries**

**Key insight from this phase:** Identified which dimensions are **high cardinality** (many distinct values, e.g. customers) vs **low cardinality** (few distinct values, e.g. gender, country) — critical for deciding how to group and aggregate in downstream analysis.

---

### Phase 6 — Ranking Analysis
> *"Who and what rises to the top — and who falls to the bottom?"*

Used `DENSE_RANK()` window functions with CTEs to ensure **ties are handled fairly** and rankings are computed on the full dataset before filtering.

**Product Rankings:**
- 🏆 Top 5 products by **highest revenue**
- 📉 Bottom 5 products by **lowest sales**
- 🏆 Top 5 **sub-categories** by revenue
- 📉 Bottom 5 **sub-categories** by sales

**Customer Rankings:**
- 💎 Top 10 customers by **highest revenue generated**
- 🔁 Top 3 customers with the **most orders placed**
- 🕐 Top 3 customers with the **fewest orders placed**

---

## 💡 Key Learnings & SQL Concepts Applied

- `GROUP BY` vs `PARTITION BY` — understanding that `PARTITION BY` is not a substitute for aggregation
- `DENSE_RANK()` over `TOP N` — handling ties correctly in ranked results
- Deterministic vs non-deterministic `TOP N` — importance of pairing `TOP` with an outer `ORDER BY`
- CTE-based ranking pattern — rank first on full data, filter outside
- `UNION ALL` for consolidated metric reporting

---

## 🛠️ Tools & Environment

- **Database:** Microsoft SQL Server
- **Schema:** Gold layer (cleansed/modelled)
- **Language:** T-SQL

---

## 📁 Repository Structure

```
📦 eda-sales-analysis
 ┣ 📂 sql
 ┃ ┣ 📄 EDA_1: This includes 01_database_exploration, 02_dimension_exploration, 03_date_exploration, 04_measure_exploration
 ┃ ┣ 📄 05_magnitude_analysis.sql
 ┃ ┗ 📄 06_ranking_analysis.sql
 ┗ 📄 README.md
```

---

*Built as a structured learning project to develop SQL analytical thinking — from schema awareness to business-ready insights.*
