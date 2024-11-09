-- orders

create table orders (
    id serial primary key,
    amount money
);

insert into orders values
(1, 500),
(2, 600),
(3, 700);

-- products

create table products (
    id serial primary key,
    price money
);

insert into products values
(1, 30),
(2, 75),
(3, 80);

-- payments

create table payments (
    id serial primary key,
    amount money
);

insert into payments values
(1, 200),
(2, 300),
(3, 400);
