# Car listings API quick reference

Base URL: `/api`

## Public routes

- `GET /cars`
- `GET /cars/:id`

Query params for `GET /cars`:
- `search`
- `city`
- `fuel`
- `gearbox`
- `minPrice`
- `maxPrice`
- `yearFrom`
- `yearTo`
- `reserved` (`true` or `false`)
- `sort` (`price_asc`, `price_desc`, `year_asc`, `year_desc`)

## Protected routes (Bearer token required)

- `GET /cars/my`
- `POST /cars`
- `PUT /cars/:id` (owner or admin)
- `DELETE /cars/:id` (owner or admin)

Example create payload:

```json
{
  "title": "Peugeot 308 1.6 HDi",
  "year": 2008,
  "km": 218000,
  "priceEur": 4200,
  "city": "Novi Sad",
  "fuel": "Dizel",
  "gearbox": "Manuelni",
  "description": "Redovno servisiran.",
  "imagePaths": []
}
```
