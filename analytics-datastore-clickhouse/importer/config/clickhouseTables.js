const CLUSTERED_MODE = process.env.CLUSTERED_MODE || "true";

const queries =
  Boolean(CLUSTERED_MODE) === true
    ? [
        `CREATE TABLE my_table(
			createdAt Date,
			updatedAt Date
		) 
		ENGINE=MergeTree
		ORDER BY tuple();`,
      ]
    : [
        // Replicated table
        `CREATE TABLE default.my_table ON CLUSTER '{cluster}' (
			createdAt Date,
			updatedAt Date
		)
		ENGINE = ReplicatedMergeTree('/clickhouse/tables/{cluster}/{shard}/my_table', '{replica}')
		ORDER BY tuple();`,
        // Distributed table : Writes and queries should be made against this table
        `CREATE TABLE default.my_table_distributed ON CLUSTER '{cluster}' AS default.my_table
		ENGINE = Distributed('{cluster}', default, my_table, rand())`,
      ];

module.exports = queries;
