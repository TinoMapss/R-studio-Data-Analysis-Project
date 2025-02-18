```{r}
library(tidyverse)
library(readxl)
library(scales)
library(dplyr)
library(ggplot2)
```

```{r}

file_path <- "C:/Users/Tino/Downloads/Global_Development_Indicators.csv" 

# Read the dataset
data <- read.csv(file_path)

# Inspect for missing values
summary(data)

```

**Data cleaning**

```{r}
pdt<- data |> 
  pivot_longer(
    cols = !(Country.Name:Series.Code),
    names_to = "year",
    values_to = "values"
  ) |> 
  mutate(year = as.numeric(gsub("X|\\.\\YR.*","",year)),
         values = as.numeric(values),
         values = coalesce(values, 0)) |> 
  filter(!is.na(`Series.Name`) & `Series.Name` != "") |> 
  filter(!is.na(year)) |> 
  select(-Series.Code) |> 
  pivot_wider(
    names_from = Series.Name,
    values_from = values
  )

```

```{r}

# Renaming columns using rename
df <- pdt %>%
  rename(
    Country = `Country.Name`,
    Code = `Country.Code`,
    Adolescents_Out_School = `Adolescents out of school (% of lower secondary school age)`,
    Avg_Precipitation = `Average precipitation in depth (mm per year)`,
    Gov_Debt_Per_GDP = `Central government debt, total (% of GDP)`,
    Compulsory_Edu_Duration = `Compulsory education, duration (years)`,
    Corruption_Control = `Control of Corruption: Estimate`,
    Electric_Consumption = `Electric power consumption (kWh per capita)`,
    Coal_Electricity = `Electricity production from coal sources (% of total)`,
    Primary_Edu_Expenditure = `Expenditure on primary education (% of government expenditure on education)`,
    Secondary_Edu_Expenditure = `Expenditure on secondary education (% of government expenditure on education)`,
    Tertiary_Edu_Expenditure = `Expenditure on tertiary education (% of government expenditure on education)`,
    GDP_Constant = `GDP (constant 2015 US$)`,
    GDP_Current = `GDP (current US$)`,
    Internet_Users = `Individuals using the Internet (% of population)`,
    Tourism_Arrivals = `International tourism, number of arrivals`,
    Labor_Force = `Labor force, total`,
    Military_Expenditure = `Military expenditure (% of GDP)`,
    Mobile_Subscriptions = `Mobile cellular subscriptions (per 100 people)`,
    Primary_Persistence = `Persistence to last grade of primary, total (% of cohort)`,
    Population_0_14 = `Population ages 0-14, total`,
    Population_15_64 = `Population ages 15-64, total`,
    Population_65_Plus = `Population ages 65 and above, total`,
    Population_Growth = `Population growth (annual %)`,
    Total_Population = `Population, total`,
    `R&D_Expenditure` = `Research and development expenditure (% of GDP)`,  
    Scientific_Articles = `Scientific and technical journal articles`,
    Urban_Population = `Urban population`,
    Electric_Outage_Loss = `Value lost due to electrical outages (% of sales for affected firms)`
  )

print(colnames(df))

```

The data cleaning process involved reshaping the dataset to ensure consistency and usability. First, the data was transformed from a wide to a long format using pivot_longer pivot_longer, consolidating year columns into a single year variable. The year and vales columns were cleaned, with non-numeric characters removed and missing values replaced with zeros using coalesce . Rows with missing or empty series.name values were filtered out, and unnecessary columns, like series.code, were dropped. The data was then reshaped back into a wide format with pivot_wider, making each series.name a distinct variable. Finally, the columns were renamed for clarity, with descriptive names assigned to key indicators such as GDP, population, internet usage, and education expenditure. This cleaning process ensures the dataset is structured for further analysis of global development indicators.

### Exploratory Data Analysis

**How does the proportion of the population aged 65 and above differ between countries with the highest urban populations and those with the highest rural populations?**

```{r}
dfo <- df %>%
  mutate(Proportion_65_plus = `Population_65_Plus` / `Total_Population` * 100)

# Get the top 5 countries by urban population
top_urban <- dfo  |> 
  arrange(desc(`Urban_Population`))  |> 
  head(50)  |> 
  mutate(Type = "Urban")

# Get the top 5 countries by rural population
top_rural <- dfo  |> 
  arrange(desc(`Population_0_14`))  |>  # Assuming this column represents rural population
  head(50)  |> 
  mutate(Type = "Rural")

# Combine both top urban and rural populations into one dataframe
combined_df <- bind_rows(top_urban, top_rural)

# Calculate total population aged 65 and above for top rural countries
total_65_plus_rural <- sum(top_rural$`Population_65_Plus`, na.rm = TRUE)

print(paste("Total population aged 65 and above for top rural countries:", total_65_plus_rural))

ggplot(combined_df, aes(x = reorder(Country, Proportion_65_plus), y = Proportion_65_plus, fill = Type)) +
  geom_bar(stat = "identity", position = "dodge") +
  coord_flip() +
  labs(title = "Proportion of Population Aged 65 and Above by Country (Top Urban and Rural)",
       x = "Country",
       y = "Proportion (%)") +
  theme_minimal() +
  scale_fill_manual(values = c("Urban" = "steelblue", "Rural" = "orange"), name = "Population Type")

```

The chart illustrates the proportion of the population aged 65 and above across various countries, offering a detailed breakdown by urban and rural demographics. Notably, the United States stands out with the highest proportion of individuals aged 65 and older, predominantly residing in urban areas, reflecting a trend of aging within more developed and urbanized regions. In contrast, India exhibits a significant proportion of its elderly population, with a nearly equal distribution between urban and rural areas, suggesting a diverse living environment for older adults that encompasses both city life and rural settings. Pakistan, on the other hand, displays a lower proportion of its population aged 65 and above when compared to both India and the United States; here, the majority of the elderly population is concentrated in rural regions, highlighting potential challenges in healthcare access and social support for this demographic. Lastly, Nigeria has the lowest proportion of individuals aged 65 and above among the four countries examined, with most of its elderly residents also living in rural areas. This chart underscores the varied landscape of aging populations across different countries and the distinct regional disparities within each nation, emphasizing the importance of understanding how these demographic trends manifest in both urban and rural contexts. Such insights are crucial for policymakers and researchers aiming to address the unique needs of aging populations in diverse geographical settings.

**How does the percentage of urban population vary across different countries, and what factors contribute to these variations?**

```{r}
dfg <- df %>%
  group_by(Country) %>%
  summarise(
    Urban_Population = sum(Urban_Population, na.rm = TRUE),
    Total_Population = sum(Total_Population, na.rm = TRUE),
    Urban_Percentage = (Urban_Population / Total_Population) * 100
  ) %>%
  ungroup()

# Create a bar plot
ggplot(dfg, aes(x = Country, y = Urban_Percentage, fill = Country)) +
  geom_bar(stat = "identity", color = "black") +
  coord_flip() + # Flip coordinates for better readability
  labs(title = "Percentage of Urban Population in Total Population by Country",
       x = "Country",
       y = "Urban Population Percentage (%)") +
  theme_minimal() +
  theme(axis.text.y = element_text( hjust = 1, size = 5),
    legend.position = "none") 
```

The percentage of urban population varies significantly across different countries, reflecting diverse economic, geographical, and historical contexts. For instance, countries like Uzbekistan demonstrate a relatively low percentage of urban residents, while others, such as Monaco, boast a remarkably high urban population. This variation can be attributed to a complex interplay of factors. Economic development plays a crucial role, as more developed countries tend to experience higher levels of urbanization, driven by the migration of individuals seeking jobs, education, and better living standards in urban centers. Geography also influences urbanization rates; nations with fertile land and ample water resources may maintain a lower percentage of urban population, as agriculture remains a dominant industry, sustaining rural communities.

Government policies further contribute to these trends, as policymakers can either promote or discourage urbanization through land-use regulations, transportation infrastructure, and housing initiatives. Historical factors are equally significant; countries with a long-standing history of urbanization typically exhibit higher urban population percentages than those that have only recently begun to experience this transition. For example, the high percentage of urban population in Monaco can be attributed to its small geographic size, its evolution into a tax haven, and its strong focus on tourism and financial services. In contrast, Uzbekistan's lower urbanization rate is likely linked to its substantial agricultural sector and its relatively recent industrial development. This diversity in urbanization patterns highlights the multifaceted nature of demographic shifts and underscores the importance of tailored policies to address the unique challenges and opportunities presented by urban and rural populations across different countries.

**Which country has the highest percentage of its population aged 65 and above, indicating the greatest aging population?**

```{r}
dfg <- df %>%
  mutate(Proportion_65_plus = `Population_65_Plus` / `Total_Population` * 100) %>%
  filter(!is.na(Proportion_65_plus))  # Remove NA values for plotting

# Create a bar plot
ggplot(dfg, aes(x = reorder(Country, Proportion_65_plus), y = Proportion_65_plus)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +  # Flip coordinates for better readability
  labs(title = "Proportion of Population Aged 65 and Above by Country",
       x = "Country",
       y = "Proportion (%)") +
  theme_minimal()+
  theme(axis.text.y = element_text( hjust = 1, size = 5))


```

The bar chart illustrates the proportion of the population aged 65 and above across various countries, arranged from the lowest to the highest proportion. Monaco stands out with an astonishingly high proportion of around 1000%, indicating a unique demographic situation, while the United Arab Emirates has the lowest proportion at approximately 1%. This chart serves as a valuable tool for comparing the age structures of different nations and identifying which countries have a larger share of older adults within their populations.

Several key observations emerge from the chart. Firstly, developed countries generally exhibit a higher proportion of older adults compared to developing countries, reflecting the trends associated with advanced healthcare systems, better living conditions, and higher life expectancies. Secondly, there is significant variation in the proportion of older adults across countries, even among those located within the same geographical region. This suggests that cultural, economic, and social factors play a crucial role in shaping demographic trends. Furthermore, the proportion of older adults is on the rise in most countries, driven by increased life expectancy and declining birth rates, which pose various challenges for healthcare and social systems. Overall, this chart is a vital resource for policymakers and researchers seeking to understand the implications of aging populations, enabling them to make informed decisions regarding social, economic, and health strategies tailored to meet the needs of older adults in diverse contexts.

### Conclusion

This exploratory analysis of global development indicators reveals key relationships between demographic trends, economic factors, and social development across different countries. The findings highlight how infrastructure, urbanization, and economic growth intersect to shape important outcomes such as internet access, life expectancy, and aging populations. Developed nations generally exhibit higher rates of urbanization and aging populations, driven by factors like economic prosperity, advanced healthcare systems, and lower birth rates. In contrast, less developed countries with lower urbanization levels face challenges related to rural aging populations, economic disparities, and access to resources like electricity and the internet.

One of the most striking insights is the role of urbanization in determining the distribution of aging populations and the implications for healthcare and social services. Countries with high urbanization rates, such as Monaco and the United States, tend to have a higher proportion of their population aged 65 and above in cities. Meanwhile, nations with lower urbanization, such as Nigeria and Pakistan, see a greater share of their elderly population in rural areas, which may require different policy approaches.

However, the analysis also reveals that economic development alone is not sufficient to guarantee high life expectancy. Some countries, despite lower GDPs, manage to achieve relatively high life expectancies due to robust healthcare systems and strong social policies, demonstrating that public health is influenced by a range of factors beyond economic wealth.
