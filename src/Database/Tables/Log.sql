CREATE TABLE [dbo].[Log]
(
  [LogId] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
  [LogDate] DATETIME NOT NULL,
  [LogText] NVARCHAR(200) NOT NULL
)
