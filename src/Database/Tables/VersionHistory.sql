CREATE TABLE [dbo].[VersionHistory]
(
  [VersionId] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
  [ReleaseDate] DATETIME NOT NULL,
  [ReleaseName] NVARCHAR(100) NOT NULL
)
