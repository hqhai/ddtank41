using System;
using System.Diagnostics;
using log4net;

namespace SqlDataProvider.BaseClass
{
    public static class ApplicationLog
    {
        private static readonly ILog log = LogManager.GetLogger(typeof(ApplicationLog));

        public static void WriteError(string message)
        {
			WriteLog(TraceLevel.Error, message);
        }

        private static void WriteLog(TraceLevel level, string messageText)
        {
			// always visible in the server's log files/console (the Windows event log is not available everywhere)
			log.Error(messageText);
			if (Environment.OSVersion.Platform != PlatformID.Win32NT)
			{
				return;
			}
			try
			{
				EventLogEntryType type = ((level != TraceLevel.Error) ? EventLogEntryType.Error : EventLogEntryType.Error);
				string str = "Application";
				if (!EventLog.SourceExists(str))
				{
					EventLog.CreateEventSource(str, "BIZ");
				}
				new EventLog(str, ".", str).WriteEntry(messageText, type);
			}
			catch
			{
			}
        }
    }
}
