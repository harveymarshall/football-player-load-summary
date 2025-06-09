import streamlit as st
import pandas as pd
import plotly.express as px

# Load the ACWR table (could be read from Athena or CSV)
df = pd.read_csv("./data/acwr_metrics.csv", parse_dates=["week"])

# Sidebar filter
player = st.selectbox("Choose a player", sorted(df["player"].unique()))

# Filtered data
player_df = df[df["player"] == player]

# ACWR line plot
fig = px.line(
    player_df,
    x="week",
    y="acwr",
    title=f"ACWR Trend for {player}",
    markers=True
)

# Add red markers for high risk
high_risk_weeks = player_df[player_df["acwr"] > 1.5]
fig.add_scatter(
    x=high_risk_weeks["week"],
    y=high_risk_weeks["acwr"],
    mode="markers",
    marker=dict(color="red", size=10),
    name="High Risk (ACWR > 1.5)"
)

# Add injured marker
injury_weeks = player_df[player_df["injured_next_week"] == True]
fig.add_scatter(
    x=injury_weeks["week"],
    y=injury_weeks["acwr"],
    mode="markers",
    marker=dict(symbol="x", size=12, color="black"),
    name="Injured"
)

st.plotly_chart(fig)


summary = df.groupby("week").agg(
    total_players=("player", "count"),
    high_risk=("risk_flag", lambda x: (x == "HIGH RISK").sum()),
    injured=("injured_next_week", "sum")
).reset_index()

fig2 = px.bar(summary, x="week", y=["high_risk", "injured"], barmode="group",
              title="High Risk Players vs Injuries per Week")
st.plotly_chart(fig2)
