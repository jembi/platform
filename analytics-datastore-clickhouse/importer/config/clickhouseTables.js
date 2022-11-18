const STATEFUL_NODES = process.env.STATEFUL_NODES || 'cluster';

const queries =
  STATEFUL_NODES === 'single'
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
