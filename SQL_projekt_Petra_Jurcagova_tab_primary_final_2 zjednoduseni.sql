/*Tvorba tabulky t_Petra_Jurcagova_project_SQL_primary_final */

/*Filtrování dat podle mzdy a čistého příjmu*/
/*value_type_code 5958 představuje mzdu a calculation_code 200 je čistá mzda*/
SELECT 
ROUND(AVG(value),0)average_wage,value_type_code, calculation_code, industry_branch_code, payroll_year, name 
FROM 
czechia_payroll cp JOIN czechia_payroll_industry_branch cpi
ON industry_branch_code = code
WHERE 
(value_type_code = 5958 AND calculation_code = 200) AND payroll_year >=2006 AND payroll_year <= 2018
GROUP BY 
value_type_code, calculation_code, industry_branch_code, payroll_year, name 
ORDER BY
payroll_year DESC, average_wage DESC,industry_branch_code DESC;

/*vytvoření pomocné tabulky*/
CREATE TABLE t_Petra_Jurcagova_average_salary AS
(SELECT 
ROUND(AVG(value),0)average_wage,value_type_code, calculation_code, industry_branch_code, payroll_year, name 
FROM 
czechia_payroll cp JOIN czechia_payroll_industry_branch cpi
ON industry_branch_code = code
WHERE 
(value_type_code = 5958 AND calculation_code = 200) AND payroll_year  >=2006 AND payroll_year <= 2018
GROUP BY 
value_type_code , calculation_code, industry_branch_code, payroll_year, name 
ORDER BY
payroll_year DESC, average_wage DESC, industry_branch_code DESC);

/*výpočet percentuálního meziročního rozdílu mezd*/
SELECT 
o.*, LAG(average_wage)OVER(PARTITION BY industry_branch_code ORDER BY payroll_year)previous_year,
ROUND((((average_wage/LAG(average_wage)OVER(PARTITION BY industry_branch_code ORDER BY payroll_year))-1)*100),1) interannual_percentage_difference
FROM
t_Petra_Jurcagova_average_salary o
ORDER BY
o.payroll_year DESC, average_wage DESC;

/*vytvoření pomocné tabulky*/
CREATE TABLE t_Petra_Jurcagova_salaries AS 
(SELECT
o.*, LAG(average_wage)OVER(PARTITION BY industry_branch_code ORDER BY payroll_year)previous_year,
ROUND((((average_wage/LAG(average_wage)OVER(PARTITION BY industry_branch_code ORDER BY payroll_year))-1)*100),1)
interannual_percentage_difference
FROM
t_Petra_Jurcagova_average_salary o
ORDER BY
o.payroll_year DESC, average_wage DESC);

/*příprava pomocných tabulek pro potraviny*/
/*vypočítaná průměrná cena potravin v jednotlivých letech*/
SELECT 
AVG(value), name, extract(YEAR FROM date_from), region_code,category_code
FROM
czechia_price cp JOIN czechia_price_category c
ON cp.category_code = c.code
GROUP BY
name, extract(YEAR FROM date_from), region_code, category_code
ORDER BY
extract(YEAR FROM date_from)DESC,region_code;

/*vytvoření pomocné tabulky*/
CREATE TABLE t_Petra_Jurcagova_average_food_price AS 
(SELECT 
ROUND(AVG(value),1)average, name, extract(YEAR FROM date_from)year, region_code,category_code
FROM 
czechia_price cp JOIN czechia_price_category c
ON cp.category_code = c.code
GROUP BY
name, extract(YEAR FROM date_from), region_code,category_code
ORDER BY
extract(YEAR FROM date_from)DESC,region_code);

/*vybrání dat - průměrná cena, jméno, rok, kód kategorie a vytvoření pomocné tabulky*/
CREATE TABLE t_Petra_Jurcagova_average_price AS 
(SELECT 
ROUND(AVG(average),1)average_price, name, year, category_code
FROM 
t_Petra_Jurcagova_average_food_price
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
t_Petra_Jurcagova_average_price p
ORDER BY 
category_code DESC,year DESC;

/*vytvoření pomocné tabulky*/
CREATE TABLE t_Petra_Jurcagova_food AS 
(SELECT 
p.*, LAG(average_price)OVER(PARTITION BY category_code ORDER BY year)average_price_last_year,
ROUND((((average_price/LAG(average_price)OVER(PARTITION BY category_code ORDER BY year))-1)*100),1)
interannual_percentage_difference_food
FROM 
t_Petra_Jurcagova_average_price p
ORDER BY 
category_code DESC,year DESC);

/*spojení pomocných tabulek pro potraviny a mzdy v letech 2018 až 2006 a vytvoření t_Petra_Jurcagova_project_SQL_primary_final_2*/
CREATE TABLE t_Petra_Jurcagova_project_SQL_primary_final AS
(SELECT 
p.average_price, p.name name_food, p.year, p.category_code, p.average_price_last_year, 
p.interannual_percentage_difference_food,m.average_wage, m.industry_branch_code,m.payroll_year, m.name, m.previous_year,
m.interannual_percentage_difference
FROM 
t_Petra_Jurcagova_food p JOIN t_Petra_Jurcagova_salaries m
ON p.year = m.payroll_year);

/*zobrazení NULL hodnot*/
SELECT 
*
FROM
t_Petra_Jurcagova_project_SQL_primary_final
WHERE 
average_price_last_year IS NULL;

