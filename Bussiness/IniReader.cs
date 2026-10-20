using System;
using System.Collections.Generic;
using System.IO;

namespace Bussiness
{
    // Managed replacement for kernel32!GetPrivateProfileString so the servers also run on Mono/Linux.
    public class IniReader
    {
        private string FilePath;

        private Dictionary<string, Dictionary<string, string>> m_sections;

        public IniReader(string _FilePath)
        {
			FilePath = _FilePath;
        }

        public string GetIniString(string Section, string Key)
        {
			if (m_sections == null)
			{
				m_sections = Load(FilePath);
			}
			if (m_sections.TryGetValue(Section, out Dictionary<string, string> keys) && keys.TryGetValue(Key, out string value))
			{
				return value;
			}
			return "";
        }

        private static Dictionary<string, Dictionary<string, string>> Load(string path)
        {
			Dictionary<string, Dictionary<string, string>> sections = new Dictionary<string, Dictionary<string, string>>(StringComparer.OrdinalIgnoreCase);
			if (!File.Exists(path))
			{
				return sections;
			}
			Dictionary<string, string> current = null;
			foreach (string raw in File.ReadAllLines(path))
			{
				string line = raw.Trim();
				if (line.Length == 0 || line[0] == ';' || line[0] == '#')
				{
					continue;
				}
				if (line[0] == '[' && line.EndsWith("]"))
				{
					string name = line.Substring(1, line.Length - 2).Trim();
					if (!sections.TryGetValue(name, out current))
					{
						current = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
						sections[name] = current;
					}
				}
				else if (current != null)
				{
					int idx = line.IndexOf('=');
					if (idx > 0)
					{
						string key = line.Substring(0, idx).Trim();
						if (!current.ContainsKey(key))
						{
							current[key] = line.Substring(idx + 1).Trim();
						}
					}
				}
			}
			return sections;
        }
    }
}
