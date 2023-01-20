const CLUSTERED_MODE = process.env.CLUSTERED_MODE || 'true';

const queries =
  Boolean(CLUSTERED_MODE) === true
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
