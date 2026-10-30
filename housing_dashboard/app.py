
import streamlit as st
import pandas as pd
import folium
from sqlalchemy import text
from streamlit_folium import st_folium

from database import engine


# ---------- PAGE CONFIGURATION ----------
st.set_page_config(
    page_title="Iranian Real Estate Dashboard",
    page_icon="🏠",
    layout="wide",
    initial_sidebar_state="expanded"
)

st.title("🏠 Iranian Real Estate Market Analysis")


# ---------- LOAD DATA ----------
@st.cache_data
def load_data():
    with engine.connect() as conn:
        return pd.read_sql(
            text("SELECT * FROM v_housing_map"),
            conn
        )


df = load_data()


# ---------- CITY FILTER ----------
cities = ["All Cities"] + sorted(
    df["city_slug"].dropna().unique().tolist()
)

selected_city = st.sidebar.selectbox(
    "Select City",
    cities
)

filtered_df = (
    df if selected_city == "All Cities"
    else df[df["city_slug"] == selected_city]
)


# ---------- STATISTICS ----------
col1, col2, col3 = st.columns(3)

with col1:
    st.metric(
        "Total Geolocated Listings",
        f"{len(filtered_df):,}"
    )

with col2:
    st.metric(
        "Median Asking Price",
        f"{filtered_df['price_value'].median():,.0f}"
    )

with col3:
    st.metric(
        "Median Price per m²",
        f"{filtered_df['price_per_sqm'].median():,.0f}"
    )


# ---------- SATELLITE MAP ----------
st.subheader("🛰️ Housing Price Satellite Map")

map_data = filtered_df.dropna(
    subset=[
        "location_latitude",
        "location_longitude",
        "price_per_sqm"
    ]
)

# Sample records to keep map rendering responsive.
map_data = map_data.sample(
    n=min(100, len(map_data)),
    random_state=42
)

if not map_data.empty:

    center = [
        map_data["location_latitude"].median(),
        map_data["location_longitude"].median()
    ]

    housing_map = folium.Map(
        location=center,
        zoom_start=11 if selected_city != "All Cities" else 6,
        tiles=None
    )

    # Satellite imagery
    folium.TileLayer(
        tiles="Esri.WorldImagery",
        name="Satellite",
        attr="Tiles © Esri and contributors"
    ).add_to(housing_map)

    # Calculate legend boundaries from all selected listings.
    low = filtered_df["price_per_sqm"].quantile(0.33)
    high = filtered_df["price_per_sqm"].quantile(0.66)

    # Housing price markers
    for _, property_row in map_data.iterrows():

        price = property_row["price_per_sqm"]

        color = (
            "green" if price <= low
            else "orange" if price <= high
            else "red"
        )

        folium.CircleMarker(
            location=[
                property_row["location_latitude"],
                property_row["location_longitude"]
            ],
            radius=4,
            color=color,
            fill=True,
            fill_color=color,
            fill_opacity=0.7,
            tooltip=f"Price/m²: {price:,.0f}"
        ).add_to(housing_map)

    # ---------- MAP LEGEND ----------
    legend_html = f"""
    <div style="
        position: fixed;
        bottom: 30px;
        left: 30px;
        z-index: 9999;
        background: #16202b;
        color: white;
        padding: 14px 18px;
        border-radius: 10px;
        border: 1px solid #445;
        font-size: 13px;
        box-shadow: 0 4px 12px #0008;
    ">
        <strong>Asking Price per m²</strong><br>
        <span style="color:#22c55e;">●</span>
        Low: ≤ {low:,.0f}<br>

        <span style="color:#f59e0b;">●</span>
        Medium: {low:,.0f} – {high:,.0f}<br>

        <span style="color:#ef4444;">●</span>
        High: > {high:,.0f}
    </div>
    """

    housing_map.get_root().html.add_child(
        folium.Element(legend_html)
    )

    st_folium(
        housing_map,
        width="100%",
        height=600,
        returned_objects=[]
    )

else:
    st.info("No mapped housing advertisements for this selection.")


# ---------- DATA PREVIEW ----------
st.subheader("📋 Housing Data Preview")

st.dataframe(
    filtered_df.head(20),
    use_container_width=True
)

st.caption(
    "Prices are advertised asking prices. "
    "Property locations may be approximate, not exact building addresses."
)
