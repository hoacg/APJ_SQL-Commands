CREATE SCHEMA `library_management` DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci ;

create table library_management.books
(
    id        int auto_increment primary key,
    book_name varchar(255)  null,
    authors   varchar(1000) null,
    publisher varchar(255)  null
);

create table library_management.students
(
    id       int auto_increment primary key,
    fullname varchar(255) null,
    email    varchar(255) null
);


create table library_management.borrow_order
(
    id          int auto_increment primary key,
    student_id  int           null,
    status      int default 1 null,
    borrow_date date          null,
    return_date date          null,
    constraint order_borrow_students_id_fk
        foreign key (student_id) references library_management.students (id)
);

create table library_management.borrow_order_detail
(
    id              int auto_increment primary key,
    borrow_order_id int null,
    book_id         int null,
    constraint borrow_order_detail_books_id_fk
        foreign key (book_id) references library_management.books (id),
    constraint borrow_order_detail_borrow_order_id_fk
        foreign key (borrow_order_id) references library_management.borrow_order (id)
);


INSERT INTO books (book_name, authors, publisher)
VALUES
       ('Lập trình Java', 'CodeGym', 'Công Nghệ'),
       ('Lập trình JavaScript', 'CodeGym', 'Công Nghệ'),
       ('Lập trình PHP', 'CodeGym', 'Công Nghệ')
       ;

INSERT INTO books (book_name, authors, publisher_name)
VALUES
       ('Lập trình Python', 'CodeGym', 'Giáo Dục'),
       ('Lập trình Scalar', 'CodeGym', 'Giáo Dục'),
       ('Lập trình Android', 'CodeGym', 'Kim Đồng')
       ;

INSERT INTO students(fullname, email)
VALUES
       ('Nguyễn Văn A', 'nguyenvana@gmail.com'),
       ('Trần Thị B', 'nguyenvana@gmail.com'),
       ('Phạm Minh C', 'nguyenvana@gmail.com');


# Cho mượn sách
INSERT INTO borrow_order(student_id, status, borrow_date)
VALUES
    (1, 1, '2019-11-11');
INSERT INTO borrow_order_detail(borrow_order_id, book_id)
VALUES
    (1, 1),
    (1, 2);


# mượn sách khác
INSERT INTO borrow_order(student_id, status, borrow_date)
VALUES
    (1, 1, '2019-11-12');

INSERT INTO borrow_order_detail(borrow_order_id, book_id)
VALUES
    (2, 3);
##---------------------------------------

SELECT s.id, s.fullname, b.status, b.borrow_date, b.id
FROM students s
JOIN borrow_order b on b.status = 1 and b.student_id = s.id;

UPDATE borrow_order
SET status = 0, return_date = now()
WHERE id = 1;


SELECT s.fullname,
       bo.borrow_date,
       b.book_name,
       case bo.status
           when 0 then 'Đã trả'
        else
            'Đang mượn'
        end as 'Trạng thái mượn sách'
FROM students s
JOIN borrow_order bo on s.id = bo.student_id
JOIN borrow_order_detail bod on bod.borrow_order_id = bo.id
JOIN books b on b.id = bod.book_id
WHERE s.id = 1;


# Liêt kê tất cả sách đang cho mượn

select b.* from books b
join borrow_order_detail bod on bod.book_id = b.id
join borrow_order bo on bod.borrow_order_id = bo.id
where bo.status = 0;


# difference between `modify` and `change`
alter table books
modify `publisher` varchar(1000);

alter table books
change `publisher` `publisher_name` varchar(2000);

# Liệt kê sách quá hạn mượn (hạn 7 ngày)
SELECT books.book_name, students.fullname, borrow_date, return_date FROM borrow_order
JOIN students ON students.id = borrow_order.student_id
JOIN borrow_order_book ON borrow_order.id = borrow_order_book.borrow_order_id
JOIN books ON borrow_order_book.book_id = books.id
WHERE status = 0 AND datediff(now(), borrow_date) > 7;

# Thống kê lượt mượn theo danh mục sách
SELECT prevResult.name, sum(prevResult.is_borrow) borrow_count FROM
(SELECT case
    when b.category_id is NULL then 0
    else 1
    end as is_borrow,
       c.name FROM categories c
LEFT JOIN books b on c.id = b.category_id
LEFT JOIN borrow_order_book bob on b.id = bob.book_id
LEFT JOIN borrow_order bo on bob.borrow_order_id = bo.id) as prevResult
GROUP BY prevResult.name
ORDER BY borrow_count DESC;
