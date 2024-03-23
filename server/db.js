const Pool = require("pg").Pool;

const pool = new Pool({
  user: "postgres",
  password: "GurjotG123",
  host: "localhost",
  port: 5432,
  database: "GoldenOasisDB"
});

module.exports = pool;
