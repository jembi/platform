const queries = [
  `CREATE TABLE default_table(
		createdAt Date,
		updatedAt Date
	  ) 
	  ENGINE=MergeTree
	  ORDER BY tuple();`,
];

module.exports = queries;
