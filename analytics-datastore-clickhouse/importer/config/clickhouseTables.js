const NODE_MODE = process.env.NODE_MODE || 'cluster';

const queries =
  NODE_MODE === 'single'
    ? [
        `CREATE TABLE default_table(
			createdAt Date,
			updatedAt Date
		) 
		ENGINE=MergeTree
		ORDER BY tuple();`,
      ]
    : [
        `CREATE TABLE default.default_table ON CLUSTER '{cluster}' (
			createdAt Date,
			updatedAt Date
		)
		ENGINE = ReplicatedMergeTree('/clickhouse/tables/{cluster}/{shard}/{table}', '{replica}')
		ORDER BY tuple();`,
      ];

module.exports = queries;
