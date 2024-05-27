-- EXPLOTATORY DATA ANALYSIS (EDA)----------------------------------------------------

-- THIS IS HOW OUR DATA LOOKS LIKE 

select *
from layoffs_duplicate2;

-- finding the maximum total_laid_off

select max(total_laid_off)
from layoffs_duplicate2;

-- finding the minimum and maximum percentage laid-off

select max(percentage_laid_off),min(percentage_laid_off)
from layoffs_duplicate2
where percentage_laid_off is not null;

-- which companies completely laid_off there employees (where percentage_laid_off is exactly 1)

select *
from layoffs_duplicate2
where percentage_laid_off =1;
-- most of the companies who completely laid_off all employees are mostly startups

-- now let's see how big some of these companies are

select *
from layoffs_duplicate2
where percentage_laid_off =1
order by funds_raised_millions desc;

-- top 10 comapanies who have most laid-off on a single day

select company,total_laid_off
from layoffs_duplicate2
order by 2 desc
limit 10;

-- top 5 companies with most laid-off in total

select company,sum(total_laid_off)
from layoffs_duplicate2
group by company
order by 2 desc
limit 5;

-- top 5 coutry with most laid-off in total

select country,sum(total_laid_off)
from layoffs_duplicate2
group by country
order by 2 desc
limit 5;

-- top 5 industry with most laid-off in total

select industry,sum(total_laid_off)
from layoffs_duplicate2
group by industry
order by 2 desc
limit 5;

-- most laid_offs in total by year

select YEAR(`date`) as years,sum(total_laid_off)
from layoffs_duplicate2
group by YEAR(`date`)
having years is not null
order by 2 desc;

-- most laid_offs in total by stage
select stage,sum(total_laid_off)
from layoffs_duplicate2
group by stage
order by 2 desc;

-- Rolling Total of layoffs per month
WITH  rolling_total as (
		select substring(`date`,1,7) as `MONTH`,sum(total_laid_off) as laid_off_in_total
		from layoffs_duplicate2
		group by `MONTH`
		order by 1 desc)
select `MONTH`,laid_off_in_total,
sum(laid_off_in_total) over (order by `MONTH` )
from rolling_total 
where `MONTH` IS NOT NULL
;

-- top 5 companies with most laid-offs in total by each year

WITH new_laid_off as (
					WITH laid_off_based_on_year as(
									select company,YEAR(`date`) as years ,sum(total_laid_off) as total_laid_off_number
									from layoffs_duplicate2
									where YEAR(`date`) is not null
									group by company,YEAR(`date`) 
									order by 3 desc)
					select *,dense_rank() over (partition by years order by total_laid_off_number desc) as ranking
					from laid_off_based_on_year
					having total_laid_off_number is not null)
select *
from new_laid_off 
where ranking <=5
;                    