/* Niko Laohoo PMG Technical Assessment Submission */


/* 1) Write a query to get the sum of impressions by day. */
SELECT date, SUM(impressions) 
FROM(marketing_performance)
GROUP BY date
ORDER BY date;

/* 2a) Write a query to get the top three revenue-generating states in order of best to worst. */
SELECT state, SUM(revenue) 
FROM website_revenue 
GROUP BY state
ORDER BY SUM(revenue) DESC
LIMIT 3;

/* 2b) How much revenue did the third best state generate?  */
/* Ohio was determined to be the third best state and it generated 37577 in revenue. */

SELECT state, SUM(revenue) 
FROM website_revenue 
GROUP BY state
ORDER BY SUM(revenue) DESC
LIMIT 1 OFFSET 2;

/* 3) Write a query that shows total cost, impressions, clicks, and revenue of each campaign. Make sure to include the campaign name in the output. */
SELECT 	wr.campaign_id, 
		wr.campaign_name,
		SUM(m.cost) AS total_cost,
        SUM(m.impressions) AS total_impressions,
        SUM(m.clicks) AS total_clicks,
        wr.total_revenue         
FROM	(SELECT campaign_id,  						/* Sub-queries sum revenue for each campaign and get the campaign name */
				c.campaign_name,
				SUM(revenue) AS total_revenue  		/* Sub-query to get the total revenue from website_revenue */
		FROM 	(SELECT id, 						
						name AS campaign_name 		/* Nested sub-query to get the campaign name from campaign_info */
				FROM campaign_info) as c
		INNER JOIN website_revenue AS w
		ON w.campaign_id = c.id
		GROUP BY campaign_id) AS wr
	INNER JOIN marketing_performance AS m
	ON m.campaign_id = wr.campaign_id
    GROUP BY wr.campaign_id
    ORDER BY wr.campaign_name;

/* 4a) Write a query to get the number of conversions of Campaign5 by state. */
SELECT geo, SUM(conversions)
FROM marketing_performance
WHERE campaign_id = (SELECT id FROM campaign_info WHERE name = 'Campaign5')
GROUP BY geo
ORDER BY SUM(conversions) DESC;

/* 4b) Which state generated the most conversions for this campaign? */
/* For Campaign5, Georgia generated the most conversions with a total of 672 conversions. */
SELECT geo, SUM(conversions)
FROM marketing_performance
WHERE campaign_id = (SELECT id FROM campaign_info WHERE name = 'Campaign5')
GROUP BY geo
ORDER BY SUM(conversions) DESC
LIMIT 1;

/* 5) In your opinion, which campaign was the most efficient, and why? */
/* Campaign5 was the most efficient since it had a significantly higher profit per impression and click as compared to the other campaigns. */

SELECT 	wr.campaign_id, 
		wr.campaign_name,
        wr.total_revenue - SUM(m.cost) AS profit, 
        (wr.total_revenue - SUM(m.cost)) / SUM(m.impressions) AS profit_per_impression,
        (wr.total_revenue - SUM(m.cost)) / SUM(m.clicks) AS profit_per_click
FROM	(SELECT campaign_id, 						/* Sub-queries sum revenue for each campaign and get the campaign name */
				c.campaign_name,
				SUM(revenue) AS total_revenue		/* Sub-query to get the total revenue from website_revenue */
		FROM 	(SELECT id, 
						name AS campaign_name		/* Nested sub-query to get the campaign name */
				FROM campaign_info) as c
		INNER JOIN website_revenue AS w
		ON w.campaign_id = c.id
		GROUP BY campaign_id) AS wr
	INNER JOIN marketing_performance AS m
	ON m.campaign_id = wr.campaign_id
    GROUP BY wr.campaign_id
    ORDER BY profit_per_impression DESC;

/* 6) Write a query that showcases the best day of the week (e.g., Sunday, Monday, Tuesday, etc.) to run ads. */
/* The results are unclear since Saturday has the highest average profit per impression, while Thursday has the 
highest average profit per click, all while Wednesday has the highest average profit. Although regardless of 
efficiency and effectiveness Wednesday is the best day to run ads simply because it generates the highest profit. */

SELECT 	wr.day_of_the_week, 
		wr.average_revenue - mp.average_cost AS average_profit,
        (wr.average_revenue - mp.average_cost) / mp.average_impressions AS average_profit_per_impression,
        (wr.average_revenue - mp.average_cost) / mp.average_clicks AS average_profit_per_click
FROM 	(SELECT DAYNAME(date) AS day_of_the_week,  			/* Sub-query averages the revenue accross days of the week for days that have both */
				AVG(revenue) AS average_revenue				/* recorded revenue (in website_revenue) and recorded cost (in marketing_performance) */
		FROM website_revenue
        WHERE date in (SELECT DISTINCT date FROM marketing_performance)
		GROUP BY day_of_the_week) AS wr
INNER JOIN 	(SELECT DAYNAME(date) AS day_of_the_week, 		/* Sub-query averages the cost accross days of the week for days that have both */
					AVG(cost) AS average_cost, 				/* recorded revenue (in website_revenue) and recorded cost (in marketing_performance) */
                    AVG(impressions) AS average_impressions, 
                    AVG(clicks) AS average_clicks
			FROM marketing_performance
            WHERE date in (SELECT DISTINCT date FROM website_revenue)
			GROUP BY day_of_the_week) AS mp
ON wr.day_of_the_week = mp.day_of_the_week
ORDER BY average_profit DESC;
