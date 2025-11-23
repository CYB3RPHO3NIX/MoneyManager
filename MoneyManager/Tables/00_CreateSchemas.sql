-- This script ensures required schemas exist before any table creation scripts are run
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'lookup')
    EXEC('CREATE SCHEMA [lookup]');

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'data')
    EXEC('CREATE SCHEMA [data]');

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'identity')
    EXEC('CREATE SCHEMA [identity]');
