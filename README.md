# Shopping Cart API

A simple shopping cart REST API built in Perl that calculates subtotals with support for special pricing and bundle discounts.

## Features

- Calculate subtotals for multiple items
- Support for special pricing (e.g., "3 for $140")
- Input validation for items and quantities
- RESTful API endpoint
- JSON-based product configuration

## Installation

Install dependencies using cpanm:

```bash
cpanm --installdeps .
```

Or using cpan:

```bash
cpan Plack JSON::MaybeXS Path::Tiny
```

## Running the Application

Start the PSGI application:

```bash
plackup app.psgi
```

The server runs on `http://localhost:5000` by default.

## API Usage

### Endpoint

`POST /checkout`

### Request Format

```json
{
  "items": [
    { "code": "A", "quantity": 3 },
    { "code": "B", "quantity": 2 },
    { "code": "C", "quantity": 1 }
  ]
}
```

### Response Format

Success (200):

```json
{
  "subtotal": 235
}
```

Error (400):

```json
{
  "error": "Error message here"
}
```

### Example with curl

```bash
curl -X POST http://localhost:5000/checkout \
  -H "Content-Type: application/json" \
  -d '{"items": [{"code": "A", "quantity": 3}, {"code": "B", "quantity": 2}]}'
```

## Product Configuration

Products are configured in [data/pricingData.json](data/pricingData.json). Each product can have:

- `unit_price`: Base price per item
- `special`: Optional bundle pricing with:
  - `count`: Number of items for the special price
  - `price`: Special price for the bundle

Example:

```json
{
  "A": {
    "unit_price": 50,
    "special": { "count": 3, "price": 140 }
  },
  "B": {
    "unit_price": 35,
    "special": { "count": 2, "price": 60 }
  },
  "C": {
    "unit_price": 25
  }
}
```

## Validation Rules

- Items field is required and must be an array
- Each item must have a `code` and `quantity`
- Quantity must be between 0 and 1000
- Duplicate product codes are not allowed
- Product codes must exist in the pricing data

## Project Structure

```
.
├── app.psgi              # PSGI application entry point
├── lib/
│   └── Checkout.pm       # Core checkout logic
├── data/
│   └── pricingData.json  # Product pricing configuration
├── cpanfile             # Perl dependencies
└── README.md            # This file
```

## Running Tests

Run tests using prove:

```bash
prove -l t/
```

Or run individual test files:

```bash
perl -Ilib t/checkout.t
```
