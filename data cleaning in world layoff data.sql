-------------- DATA CLEANING  ON WORLD LAYOFFS DATA
-- OUR OBJECTIVES
-- removing any duplicates
-- removing any unnecessary columns
-- standardize the data
-- null values or blank values

-- 1) removing any duplicates
-- first we will make duplicate column incase we dont miss our data
CREATE TABLE layoffs_duplicate
like layoffs;

INSERT layoffs_duplicate
select *
from layoffs;

select * 
from (
	select *,
	row_number() over(partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
	from layoffs_duplicate) as rt
where rt.row_num >1 ;

-- since delete function dont work on cte/subquery so we are going to make another table
CREATE TABLE `layoffs_duplicate2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- finding the row_number for each row on the required partition inorder to find the duplicate rows
insert into layoffs_duplicate2
select *,
row_number() over(partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
from layoffs_duplicate ;

-- removing the duplicate rows
delete
from layoffs_duplicate2
where row_num >1;
 
-- duplicate rows are removed
select *
from layoffs_duplicate2
where row_num >1;

-- 2) Standardizing the data

select distinct (industry)
from layoffs_duplicate2;

-- formatting the company column 
update layoffs_duplicate2
set company=trim(company)
;

-- formatting the industry column
update layoffs_duplicate2
set industry='Crypto'
where industry like 'Crypto%';

select distinct country,trim(Trailing '.' from country)
from layoffs_duplicate2
order by  1 asc;

-- formatting the country column
update layoffs_duplicate2
set country=trim(Trailing '.' from country)
where country like 'United States%';

select date,str_to_date(`date`,'%m/%d/%Y')
from layoffs_duplicate2
;

-- updating the date column format into date format
UPDATE layoffs_duplicate2
SET `date`=str_to_date(`date`,'%m/%d/%Y')
;

-- changing the data type of date column
ALTER TABLE layoffs_duplicate2
MODIFY COLUMN `date` DATE;

select `date`
from layoffs_duplicate2;

-- finding the rows where company rows are missing 
select company,industry
from layoffs_duplicate2
where industry is null ;

-- UPDATING THE BLANK VALUES OF INDUSTRY INTO NULL VALUES
update layoffs_duplicate2
set industry=NULL
where industry='';

-- SELF JOINING THE TABLE TO FIND OUT THE COMPANIES WHO INDUSTRY NAME IS MISSING IN SOME ROWS
select t1.industry,t2.industry
from layoffs_duplicate2 t1
join layoffs_duplicate2 t2
	on t1.company=t2.company
where t1.industry is null
and t2.industry is not null
;

-- UPDATING THE ROWS WHERE INDUSTRY NAME IS MISSING AND POPULATING WITH THE ROWS WHERE COMPANY INDUSTRY IS PRESENT
UPDATE layoffs_duplicate2 t1
join layoffs_duplicate2 t2
	on t1.company=t2.company
set t1.industry=t2.industry
where t1.industry is null
and t2.industry is not null
;

select *
from layoffs_duplicate2
where total_laid_off is null
and percentage_laid_off is null
;

-- DELETING THOSE ROWS WHERE total_laid_off,percentage_laid_off values are null
DELETE 
from layoffs_duplicate2
where total_laid_off is null
and percentage_laid_off is null
;

-- DROPPING THE UNREQUIRED COLUMN
ALTER TABLE layoffs_duplicate2
DROP COLUMN row_num
;