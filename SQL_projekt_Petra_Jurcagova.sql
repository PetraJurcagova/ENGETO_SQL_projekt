/*Tvorba tabulky t_Petra_Jurcagova_project_SQL_primary_final_2 */

/*Spojení tabulek czechia_payroll a czechia_payroll_industry_branch*/
SELECT 
*
FROM 
czechia_payroll cp JOIN czechia_payroll_industry_branch cpi
ON industry_branch_code = code;

/*vytvoření pomocné tabulky*/
CREATE TABLE t_Petra_Jurcagova_mzdy_podle_prum_odvetvi AS
(SELECT
*
FROM
czechia_payroll cp JOIN czechia_payroll_industry_branch cpi
ON industry_branch_code = code);

/*Filtrování dat podle mzdy a čistého příjmu*/
/*value_type_code 5958 představuje mzdu a calculation_code 200 je čistá mzda*/
SELECT 
ROUND(AVG(value),0)average_wage,value_type_code, calculation_code, industry_branch_code, payroll_year, name 
FROM 
t_Petra_Jurcagova_mzdy_podle_prum_odvetvi
WHERE 
(value_type_code = 5958 AND calculation_code = 200) AND payroll_year >=2006 AND payroll_year <= 2018
GROUP BY 
value_type_code, calculation_code, industry_branch_code, payroll_year, name 
ORDER BY
payroll_year DESC, average_wage DESC,industry_branch_code DESC;

/*vytvoření pomocné tabulky*/
CREATE TABLE t_Petra_Jurcagova_Prumerne_mzdy_odvetvi AS
(SELECT 
ROUND(AVG(value),0)average_wage,value_type_code, calculation_code, industry_branch_code, payroll_year, name 
FROM 
t_Petra_Jurcagova_mzdy_podle_odvetvi
WHERE 
(value_type_code = 5958 AND calculation_code = 200) AND payroll_year  >=2006 AND payroll_year <= 2018
GROUP BY 
value_type_code , calculation_code, industry_branch_code, payroll_year, name 
ORDER BY
payroll_year DESC, average_wage DESC, industry_branch_code DESC);

/*výpočet percentuálního meziročního rozdílu mezd*/
SELECT 
o.*, LAG(average_wage)OVER(PARTITION BY industry_branch_code ORDER BY payroll_year),
ROUND((((average_wage/LAG(average_wage)OVER(PARTITION BY industry_branch_code ORDER BY payroll_year))-1)*100),1)
FROM
t_Petra_Jurcagova_Prumerne_mzdy_odvetvi o
ORDER BY
o.payroll_year DESC, average_wage DESC;

/*vytvoření pomocné tabulky*/
CREATE TABLE t_Petra_Jurcagova_pomocna_platy AS 
(SELECT
o.*, LAG(average_wage)OVER(PARTITION BY industry_branch_code ORDER BY payroll_year)previous_year,
ROUND((((average_wage/LAG(average_wage)OVER(PARTITION BY industry_branch_code ORDER BY payroll_year))-1)*100),1)
interannual_percentage_difference
FROM
t_Petra_Jurcagova_Prumerne_mzdy_odvetvi o
ORDER BY
o.payroll_year DESC, average_wage DESC);

/*příprava pomocných tabulek pro potraviny*/
SELECT
*
FROM
czechia_price cp JOIN czechia_price_category c
ON cp.category_code = c.code

/*vytvoření pomocné tabulky*/
CREATE TABLE t_Petra_Jurcagova_ceny_potravin_kategorie_potravin AS
(SELECT
*
FROM
czechia_price cp JOIN czechia_price_category c
ON cp.category_code = c.code);

/*vypočítaná průměrná cena potravin v jednotlivých letech*/
SELECT 
AVG(value), name, extract(YEAR FROM date_from), region_code,category_code
FROM 
t_Petra_Jurcagova_ceny_potravin_kategorie_potravin
GROUP BY
name, extract(YEAR FROM date_from), region_code, category_code
ORDER BY
extract(YEAR FROM date_from)DESC,region_code;

/*vytvoření pomocné tabulky*/
CREATE TABLE t_Petra_Jurcagova_prumerCenaPotravin_roky AS 
(SELECT 
ROUND(AVG(value),1)average, name, extract(YEAR FROM date_from)year, region_code,category_code
FROM 
t_Petra_Jurcagova_ceny_potravin_kategorie_potravin
GROUP BY
name, extract(YEAR FROM date_from), region_code,category_code
ORDER BY
extract(YEAR FROM date_from)DESC,region_code);

/*vybrání dat - průměrná cena, jméno, rok, kód kategorie*/
SELECT 
ROUND(AVG(average),1)average_price, name, year, category_code
FROM 
t_Petra_Jurcagova_prumerCenaPotravin_roky
GROUP BY
year, name,category_code
ORDER BY 
year DESC;

/*vytvoření pomocné tabulky*/
CREATE TABLE t_Petra_Jurcagova_Prumerna_cena_za_roky AS 
(SELECT 
ROUND(AVG(average),1)average_price, name, year, category_code
FROM 
t_Petra_Jurcagova_prumerCenaPotravin_roky
GROUP BY
year, name,category_code
ORDER BY 
year DESC);

/*výpočet meziročního procentuálního rozdílu ceny jednotlivých potravin*/
SELECT 
p.*, LAG(average_price)OVER(PARTITION BY category_code ORDER BY year)average_price_last_year,
ROUND((((average_price/LAG(average_price)OVER(PARTITION BY category_code ORDER BY year))-1)*100),1)
interannual_percentage_difference_food
FROM 
t_Petra_Jurcagova_Prumerna_cena_za_roky p
ORDER BY 
category_code DESC,year DESC;

/*vytvoření pomocné tabulky*/
CREATE TABLE t_Petra_Jurcagova_pomocna_Potraviny_2 AS 
(SELECT 
p.*, LAG(average_price)OVER(PARTITION BY category_code ORDER BY year)average_price_last_year,
ROUND((((average_price/LAG(average_price)OVER(PARTITION BY category_code ORDER BY year))-1)*100),1)
interannual_percentage_difference_food
FROM 
t_Petra_Jurcagova_Prumerna_cena_za_roky p
ORDER BY 
category_code DESC,year DESC);

/*spojení pomocných tabulek pro potraviny a mzdy v letech 2018 až 2006*/
SELECT 
p.*, m.*
FROM 
t_Petra_Jurcagova_pomocna_Potraviny_2 p JOIN t_Petra_Jurcagova_pomocna_platy m
ON p.year = m.payroll_year;

/*vytvoření t_Petra_Jurcagova_project_SQL_primary_final_2*/
CREATE TABLE t_Petra_Jurcagova_project_SQL_primary_final_2 AS
(SELECT 
p.average_price, p.name name_food, p.year, p.category_code, p.average_price_last_year, 
p.interannual_percentage_difference_food,m.average_wage, m.industry_branch_code,m.payroll_year, m.name, m.previous_year,
m.interannual_percentage_difference
FROM 
t_Petra_Jurcagova_pomocna_Potraviny_2 p JOIN t_Petra_Jurcagova_pomocna_platy m
ON p.year = m.payroll_year);

/*zobrazení NULL hodnot*/
SELECT 
*
FROM
t_Petra_Jurcagova_project_SQL_primary_final_2
WHERE 
average_price_last_year IS NULL;
/*============================================================================================================================*/
/*Tvorba tabulky t_Petra_Jurcagova_project_SQL_secondary_final*/

/*z tabulky countries jsou vybrané jen evropské státy*/
SELECT 
country , continent, region_in_world  
FROM 
countries c
WHERE 
continent = 'Europe';

/*spojení tabulek pro celý svet*/
SELECT 
c.country, c.continent, c.region_in_world,e.country, e.YEAR, e.GDP HDP, e.gini
FROM
economies e,countries c
WHERE 
e.country = c.country; 

/*spojení tabulek economies a countries, kde jsou vybrané jen evropské státy*/
SELECT 
c.country, c.continent, c.region_in_world,e.country, e.YEAR, e.GDP HDP,e.gini, e.population
FROM
economies e JOIN countries c ON 
e.country = c.country
WHERE 
c.continent LIKE 'Eur%' AND YEAR >= 2006 AND YEAR <= 2018
ORDER BY 
YEAR DESC; 

/*vytvoření pomocné tabulky*/
CREATE TABLE t_Petra_Jurcagova_pomocna_tabulka_svet AS (SELECT 
c.country, c.continent, c.region_in_world, e.YEAR, e.GDP HDP,e.gini, e.population
FROM
economies e JOIN countries c ON 
e.country = c.country
WHERE 
c.continent LIKE 'Eur%' AND YEAR >= 2006 AND YEAR <= 2018
ORDER BY 
YEAR DESC);

/*stanovení meziročního percentuálního rozdílu HDP v evropských zemích s využitím funkce LAG*/
SELECT 
S.*,LAG(HDP) OVER(PARTITION BY country ORDER BY year )HDP_last_year,
ROUND(((HDP/LAG(HDP) OVER(PARTITION BY country ORDER BY year )-1)*100),1)interannual_percentage_difference
FROM 
t_Petra_Jurcagova_pomocna_tabulka_svet S
ORDER BY
YEAR DESC, country;

/*finalni podoba tabulky*/
CREATE TABLE t_Petra_Jurcagova_project_SQL_secondary_final AS 
(SELECT 
S.*,LAG(HDP) OVER(PARTITION BY country ORDER BY year )HDP_last_year,
ROUND(((HDP/LAG(HDP) OVER(PARTITION BY country ORDER BY year )-1)*100),1)interannual_percentage_difference
FROM 
t_Petra_Jurcagova_pomocna_tabulka_svet S
ORDER BY
YEAR DESC, country);

/*zobrazení NULL hodnot*/
SELECT 
*
FROM
t_Petra_Jurcagova_project_SQL_secondary_final
WHERE 
gini IS NULL OR HDP IS NULL;
/*==============================================================================================================================*/
/*SADA SQL PRO ODPOVĚZENÍ VÝZKUMNÝCH OTÁZEK*/

/*1.Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?*/
SELECT 
*
FROM 
t_Petra_Jurcagova_project_SQL_primary_final_2;

/*výpočet průměrného meziročního percentuálního rozdílu mezd v období 2018 až 2006*/
SELECT 
name, ROUND(AVG(interannual_percentage_difference),1)average_wage_growth
FROM 
t_Petra_Jurcagova_project_SQL_primary_final_2
GROUP BY
name
ORDER BY
average_wage_growth;

/*2.Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech 
cen a mezd?*/

/*vybrání sledovaných položek pro první (2006) a poslední sledované období (2018) a výpočet průměrné ceny za měrnou jednotku*/
SELECT 
name_food,YEAR,AVG(average_wage)average_wage_year, FLOOR(AVG(average_wage)/average_price) amount
FROM 
t_Petra_Jurcagova_project_SQL_primary_final_2
WHERE 
(name_food LIKE 'Ml%' OR name_food LIKE 'Chl%') AND (year = 2006 OR year = 2018)
GROUP BY 
year,name_food;

/*3.Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?*/

/*průměrný meziroční procentuální nárůst cen potravin v letech 2006 až 2018*/
SELECT 
ROUND(AVG(Sub.interannual_percentage_difference_food),1)price_increase,Sub.name_food
FROM
(SELECT 
DISTINCT name_food,category_code, interannual_percentage_difference_food,year
FROM 
t_Petra_Jurcagova_project_SQL_primary_final_2)Sub
GROUP BY
Sub.name_food
ORDER BY 
price_increase;
 
/*4.Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?*/

/*nárůst cen potravin a výše mezd v rámci meziročního percentuálního rozdílu v letech 2006 až 2018*/
SELECT 
ROUND(AVG(interannual_percentage_difference_food),1)food, ROUND(AVG(interannual_percentage_difference),1)wage, payroll_year
FROM
t_Petra_Jurcagova_project_SQL_primary_final_2
GROUP BY
payroll_year DESC;

/*5.Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji
v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?*/

/*z tabulky secondary_final vybrání dat pro ČR*/
SELECT 
*
FROM 
t_Petra_Jurcagova_project_SQL_secondary_final
WHERE 
country LIKE 'Cz%'
ORDER BY 
YEAR DESC;

/*vytvoření pomocné tabulky*/
CREATE TABLE t_Petra_Jurcagova_percantage_difference AS
(SELECT 
ROUND(AVG(interannual_percentage_difference_food),1)food, ROUND(AVG(interannual_percentage_difference),1)wage, payroll_year
FROM
t_Petra_Jurcagova_project_SQL_primary_final_2
GROUP BY
payroll_year DESC);

/*srovnání dat pro ČR mezi lety 2006 až 2018, HDP, gini koeficientem,
populací a meziročním percentuálním rozdílem HDP, cen potravim a mezd*/
SELECT 
Sc.YEAR,Sc.country,Sc.HDP,Sc.gini,Sc.population,Sc.HDP_last_year, Sc.interannual_percentage_difference HDP_percentage_difference,
Pf.food,Pf.wage,Pf.payroll_year
FROM 
t_Petra_Jurcagova_project_SQL_secondary_final Sc JOIN t_Petra_Jurcagova_percantage_difference Pf
ON Sc.YEAR = Pf.payroll_year
WHERE 
country LIKE 'Cz%'
ORDER BY 
payroll_year DESC;

