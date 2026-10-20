// Recovered by decompiling the original Game.Server.dll (Road.Service/bin/Release/net48, commit b1a26bc);
// no source for this script survived. It was compiled against this engine version.
using Game.Logic.AI;

namespace GameServerScript.AI.Game;

public class GamazonForestSimpleGame : APVEGameControl
{
	public override void OnCreated()
	{
		base.OnCreated();
		base.Game.SetupMissions("800,801");
		base.Game.TotalMissionCount = 1;
	}

	public override void OnPrepated()
	{
		base.OnPrepated();
	}

	public override int CalculateScoreGrade(int score)
	{
		base.CalculateScoreGrade(score);
		if (score > 900)
		{
			return 3;
		}
		if (score > 825)
		{
			return 2;
		}
		if (score > 725)
		{
			return 1;
		}
		return 0;
	}

	public override void OnGameOverAllSession()
	{
		base.OnGameOverAllSession();
	}
}
