USE world_layoffs;
SELECT *
FROM layoffs;

CREATE TABLE layoffs_staging LIKE layoffs;
INSERT layoffs_staging
SELECT * FROM layoffs;
SELECT * FROM layoffs_staging;

WITH duplicate_cte AS(
SELECT *,
ROW_NUMBER() OVER( 
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
FROM layoffs_staging
)

SELECT * FROM duplicate_cte WHERE row_num>1;

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * FROM layoffs_staging2;
INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER( 
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
FROM layoffs_staging;

SELECT * FROM layoffs_staging2 WHERE row_num>1;
DELETE FROM layoffs_staging2 WHERE row_num>1;
SELECT * FROM layoffs_staging2 WHERE row_num>1;
SELECT company FROM layoffs_staging2;
SELECT company, trim(company) FROM layoffs_staging2;

UPDATE layoffs_staging2 
SET company = trim(company);

SELECT DISTINCT industry FROM layoffs_staging2 ORDER BY 1;
UPDATE layoffs_staging2 SET industry = 'Crypto' WHERE industry LIKE '%Crypto%';
UPDATE layoffs_staging2 
SET industry = trim(industry);
UPDATE layoffs_staging2 
SET location = trim(location);
SELECT DISTINCT industry FROM layoffs_staging2 ORDER BY 1;
SELECT DISTINCT location FROM layoffs_staging2 ORDER BY 1;
UPDATE layoffs_staging2 
SET country = trim(country);
SELECT DISTINCT country FROM layoffs_staging2 ORDER BY 1;
UPDATE layoffs_staging2 
SET country = trim(TRAILING '.' FROM country) WHERE country LIKE 'UNITED STATES%';

SELECT `date`, str_to_date(`date`, '%m/%d/%Y') FROM layoffs_staging2 ;

UPDATE layoffs_staging2 SET `date` = str_to_date(`date`, '%m/%d/%Y');
ALTER table layoffs_staging2 MODIFY COLUMN `date` DATE;


UPDATE layoffs_staging2 
SET industry = NULL WHERE industry = '';


SELECT t1.industry,t2.industry 
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry 
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;

SELECT * FROM layoffs_staging2 WHERE company = 'Airbnb';
SELECT * FROM layoffs_staging2;

ALTER TABLE layoffs_staging2 DROP COLUMN row_num;
SELECT * FROM layoffs_staging2;






SELECT * 
FROM layoffs_staging2 WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2 GROUP BY company Order BY 2 DESC;

SELECT MIN(`date`) , MAX(`date`)
FROM layoffs_staging2 GROUP BY company Order BY 2 DESC;

SELECT substring(`date`,6,2) AS `MONTH`, sum(total_laid_off)
FROM layoffs_staging2
WHERE substring(`date`,1,7) IS NOT NULL
group by `MONTH` ORDER BY 1 ASC

















