-- Which staff members made the highest revenue for each store and deserve a bonus for the year 2017?

-- 1)
SELECT
    staff.staff_id,
    staff.store_id,
    staff.first_name,
    staff.last_name,
    SUM(payment.amount) AS total_revenue
FROM
    payment
JOIN
    staff ON payment.staff_id = staff.staff_id
WHERE
    EXTRACT(YEAR FROM payment.payment_date) = 2017
GROUP BY
    staff.staff_id, staff.store_id, staff.first_name, staff.last_name 
ORDER BY
	total_revenue DESC;
	
-- 2)
WITH revenue_summary AS (
    SELECT
        staff.staff_id,
        staff.store_id,
	    staff.first_name,
	    staff.last_name,
        SUM(payment.amount) AS total_revenue
    FROM
        payment
    JOIN
        staff ON payment.staff_id = staff.staff_id
    WHERE
        EXTRACT(YEAR FROM payment.payment_date) = 2017
    GROUP BY
        staff.staff_id, staff.store_id, staff.first_name, staff.last_name 
)
SELECT
	*
FROM
	revenue_summary
ORDER BY
	total_revenue DESC;

-- ******************************************************

-- Which five movies were rented more than the others, and what is the expected age of the audience for these movies?

-- 1)
SELECT
    film.title,
    film.rating,
    COUNT(rental.rental_id) AS total_rentals
FROM
    rental
JOIN
    inventory ON rental.inventory_id = inventory.inventory_id
JOIN
    film ON inventory.film_id = film.film_id
GROUP BY
    film.title, film.rating
ORDER BY
    total_rentals DESC,
	film.title ASC
LIMIT 5;

-- 2)

WITH rental_counts AS (
    SELECT
        film.title,
        film.rating,
        COUNT(rental.rental_id) AS total_rentals
    FROM
        rental
    JOIN
        inventory ON rental.inventory_id = inventory.inventory_id
    JOIN
        film ON inventory.film_id = film.film_id
    GROUP BY
        film.title, film.rating
)
SELECT
	rental_counts.title,
    rental_counts.rating,
    rental_counts.total_rentals
FROM
	rental_counts
ORDER BY
    rental_counts.total_rentals DESC,
	rental_counts.title ASC
LIMIT 5;

-- 3)

SELECT
    film.title,
    film.rating,
    (
        SELECT
            COUNT(rental.rental_id)
        FROM
            rental
        JOIN
            inventory ON rental.inventory_id = inventory.inventory_id
        WHERE
            inventory.film_id = film.film_id
    ) AS total_rentals
FROM
    film
ORDER BY
    total_rentals DESC,
	film.title ASC
LIMIT 5;


-- ******************************************************

-- Which actors/actresses didn't act for a longer period of time than the others?

-- 1)
SELECT
    actor.first_name,
    actor.last_name,
    MAX(YEAR(film.release_year)) AS last_f_year,
	EXTRACT (YEAR FROM CURRENT_DATE) - MAX(film.release_year) AS years_since_last_film
FROM
    actor
JOIN
    film_actor ON actor.actor_id =  film_actor.actor_id
JOIN
    film ON film_actor.film_id = film.film_id
GROUP BY
    actor.first_name, actor.last_name
ORDER BY
    years_since_last_film DESC,
	first_name ASC
LIMIT 10;


-- 2)

WITH actor_last_film AS (
    SELECT
        actor.actor_id,
        actor.first_name,
        actor.last_name,
        MAX(film.release_year) OVER (PARTITION BY actor.actor_id) AS last_f_year
    FROM
        actor
	JOIN
		film_actor ON actor.actor_id =  film_actor.actor_id
	JOIN
		film ON film_actor.film_id = film.film_id
)
SELECT
    first_name,
    last_name,
    last_f_year,
    EXTRACT(YEAR FROM CURRENT_DATE) - last_f_year AS years_since_last_film
FROM
    actor_last_film
GROUP BY
    actor_id, first_name, last_name, last_f_year
ORDER BY
    years_since_last_film DESC,
    first_name ASC
LIMIT 10;