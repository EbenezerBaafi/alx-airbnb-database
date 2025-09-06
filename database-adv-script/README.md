# SQL JOIN Queries for Airbnb-like Platform

## 📋 Project Overview

This repository contains SQL JOIN queries designed for an Airbnb-like vacation rental platform. The queries demonstrate different types of JOIN operations to retrieve data from multiple related tables while handling various data relationship scenarios.

## 🗄️ Database Schema

### Tables Used

#### **User Table**
```sql
CREATE TABLE User (
    user_id VARCHAR(36) PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20) NULL,
    role ENUM('guest', 'host', 'admin') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### **Booking Table**
```sql
CREATE TABLE Booking (
    booking_id VARCHAR(36) PRIMARY KEY,
    property_id VARCHAR(36) NOT NULL,
    user_id VARCHAR(36) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    status ENUM('pending', 'confirmed', 'canceled') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (property_id) REFERENCES Property(property_id),
    FOREIGN KEY (user_id) REFERENCES User(user_id)
);
```

#### **Property Table**
```sql
CREATE TABLE Property (
    property_id VARCHAR(36) PRIMARY KEY,
    host_id VARCHAR(36) NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    location VARCHAR(255) NOT NULL,
    price_per_night DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (host_id) REFERENCES User(user_id)
);
```

#### **Review Table**
```sql
CREATE TABLE Review (
    review_id VARCHAR(36) PRIMARY KEY,
    property_id VARCHAR(36) NOT NULL,
    user_id VARCHAR(36) NOT NULL,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5) NOT NULL,
    comment TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (property_id) REFERENCES Property(property_id),
    FOREIGN KEY (user_id) REFERENCES User(user_id)
);
```

## 🔗 JOIN Operations Implemented

### 1. INNER JOIN - Bookings with Users

**Purpose**: Retrieve all bookings and the respective users who made those bookings

**Use Case**: 
- Ensures data integrity by only showing bookings with valid user references
- Perfect for generating booking reports with user information
- Excludes any orphaned bookings

**Key Features**:
- Returns only matching records from both tables
- Includes user details (name, email, role) with booking information
- Ordered by most recent bookings first

**Query Location**: `inner_join_bookings_users.sql`

---

### 2. LEFT JOIN - Properties with Reviews

**Purpose**: Retrieve all properties and their reviews, including properties that have no reviews

**Use Case**:
- Display property listings where some properties might be new/unreviewed
- Show review statistics for each property
- Identify properties that need marketing to get first reviews

**Key Features**:
- Returns ALL properties regardless of review status
- Shows NULL values for review columns where no reviews exist
- Includes reviewer information from User table
- Provides review statistics and rating categories

**Query Location**: `left_join_properties_reviews.sql`

---

### 3. FULL OUTER JOIN - Users and Bookings

**Purpose**: Retrieve all users and all bookings, even if the user has no booking or a booking is not linked to a user

**Use Case**:
- Data quality analysis and integrity checking
- User engagement analysis (registered vs. active users)
- Identify orphaned bookings that need cleanup
- Business intelligence for conversion tracking

**Key Features**:
- Shows ALL users (including those who never booked)
- Shows ALL bookings (including orphaned ones)
- Categorizes relationships for easy analysis
- Provides user engagement statistics

**Query Location**: `full_outer_join_users_bookings.sql`


```

## 🚀 Getting Started

### Prerequisites
- MySQL 5.7+ or PostgreSQL 10+
- Database client (MySQL Workbench, pgAdmin, or similar)
- Basic understanding of SQL JOIN operations

### Setup Instructions

1. **Create Database**
   ```sql
   CREATE DATABASE airbnb_platform;
   USE airbnb_platform;
   ```

2. **Create Tables**
   ```bash
   # Execute schema files in order:
   mysql -u username -p airbnb_platform < schema/user_table.sql
   mysql -u username -p airbnb_platform < schema/property_table.sql
   mysql -u username -p airbnb_platform < schema/booking_table.sql
   mysql -u username -p airbnb_platform < schema/review_table.sql
   ```

3. **Insert Sample Data** (Optional)
   ```sql
   -- Add sample users, properties, bookings, and reviews
   -- for testing the JOIN queries
   ```

4. **Execute JOIN Queries**
   ```bash
   # Run individual query files
   mysql -u username -p airbnb_platform < queries/inner_join_bookings_users.sql
   ```

## 📊 Query Results Expected

### INNER JOIN Results
- **Records Returned**: Only bookings with valid user references
- **Data Integrity**: Guaranteed - no orphaned records
- **Use Case**: Production reports, user booking history

### LEFT JOIN Results
- **Records Returned**: All properties + their reviews (if any)
- **NULL Handling**: Properties without reviews show NULL in review columns
- **Use Case**: Property listings, review analytics

### FULL OUTER JOIN Results
- **Records Returned**: All users + all bookings (regardless of relationships)
- **Data Quality**: Shows orphaned records and unused accounts
- **Use Case**: Data analysis, integrity audits, business intelligence

## 🔍 Query Variations Included

Each JOIN type includes multiple query variations:

### **Basic Queries**
- Simple SELECT with essential columns
- Straightforward JOIN syntax
- Easy to understand and modify

### **Enhanced Queries**
- Calculated fields (nights stayed, average ratings)
- String concatenation for better formatting
- Date calculations and aggregations

### **Statistical Queries**
- COUNT, AVG, SUM aggregations
- GROUP BY for summary statistics
- Data categorization with CASE statements

### **Data Quality Queries**
- Integrity checking
- Orphaned record identification
- Relationship validation

## 💡 Learning Objectives

After working with these queries, you should understand:

1. **INNER JOIN**: Returns only matching records from both tables
2. **LEFT JOIN**: Returns all records from left table + matching from right
3. **FULL OUTER JOIN**: Returns all records from both tables
4. **NULL Handling**: Using COALESCE, IS NULL, NULLS LAST
5. **Data Relationships**: Foreign keys and referential integrity
6. **Aggregation**: COUNT, AVG, SUM with GROUP BY
7. **Conditional Logic**: CASE statements for data categorization

## 🛠️ Tools and Technologies

- **Database**: MySQL/PostgreSQL
- **IDE**: VS Code with SQL extensions
- **Version Control**: Git
- **Documentation**: Markdown

## 📈 Performance Considerations

### **Indexing Recommendations**
```sql
-- Primary keys are automatically indexed
-- Add indexes for foreign keys used in JOINs
CREATE INDEX idx_booking_user_id ON Booking(user_id);
CREATE INDEX idx_booking_property_id ON Booking(property_id);
CREATE INDEX idx_review_property_id ON Review(property_id);
CREATE INDEX idx_review_user_id ON Review(user_id);
```

### **Query Optimization Tips**
- Use appropriate WHERE clauses to filter early
- Consider LIMIT for large datasets
- Use EXPLAIN to analyze query execution plans
- Monitor query performance in production

## 🔒 Security Considerations

- **SQL Injection Prevention**: Use parameterized queries in applications
- **Data Privacy**: Be careful with personal information in results
- **Access Control**: Implement proper database user permissions
- **Audit Logging**: Track data access for compliance

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-join-query`)
3. Commit your changes (`git commit -am 'Add new JOIN variation'`)
4. Push to the branch (`git push origin feature/new-join-query`)
5. Create a Pull Request

### **Contribution Guidelines**
- Follow SQL naming conventions
- Include comments in complex queries
- Add performance notes for expensive operations
- Update README for new query types

## 🐛 Troubleshooting

### **Common Issues**

#### **"Unknown column" errors**
- **Solution**: Verify table and column names match your schema
- **Check**: Case sensitivity in table/column names

#### **"Table doesn't exist" errors**  
- **Solution**: Ensure tables are created in correct order (dependencies)
- **Check**: Database connection and schema selection

#### **Performance issues with large datasets**
- **Solution**: Add appropriate indexes
- **Check**: Query execution plans with EXPLAIN

#### **FULL OUTER JOIN not supported**
- **Solution**: MySQL doesn't support FULL OUTER JOIN natively
- **Alternative**: Use UNION of LEFT JOIN and RIGHT JOIN

```sql
-- MySQL FULL OUTER JOIN alternative
SELECT * FROM User u LEFT JOIN Booking b ON u.user_id = b.user_id
UNION
SELECT * FROM User u RIGHT JOIN Booking b ON u.user_id = b.user_id;
```

## 📚 Additional Resources

- [MySQL JOIN Documentation](https://dev.mysql.com/doc/refman/8.0/en/join.html)
- [PostgreSQL JOIN Documentation](https://www.postgresql.org/docs/current/queries-table-expressions.html#QUERIES-JOIN)
- [SQL JOIN Visual Explanation](https://www.w3schools.com/sql/sql_join.asp)
- [Database Normalization Guide](https://www.guru99.com/database-normalization.html)

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Authors

- **Your Name** - Initial work and query development
- **Contributors** - See [CONTRIBUTORS.md](CONTRIBUTORS.md) for list of contributors

## 📞 Support

For questions or issues:
- Create an issue in the GitHub repository
- Contact: your.email@example.com
- Documentation: Check the `/documentation` folder

---

## 📋 Quick Reference

### **Query Execution Order**
1. Execute INNER JOIN first (validates basic relationships)
2. Execute LEFT JOIN second (shows missing relationships)
3. Execute FULL OUTER JOIN last (complete data analysis)

### **Key SQL Concepts Demonstrated**
- ✅ INNER JOIN (intersection)
- ✅ LEFT JOIN (all from left table)  
- ✅ FULL OUTER JOIN (union of both tables)
- ✅ Foreign Key Relationships
- ✅ NULL Handling
- ✅ Aggregation Functions
- ✅ Conditional Logic (CASE)
- ✅ Data Categorization
- ✅ Performance Optimization

**Last Updated**: January 2025