-- This file contains SQL statements that will be executed after the build script.
INSERT INTO dbo.VersionHistory(ReleaseDate, ReleaseName)
VALUES(GETDATE(), '1.0.0')