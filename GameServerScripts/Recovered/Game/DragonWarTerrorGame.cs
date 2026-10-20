// Recovered by decompiling the original Game.Server.dll (Road.Service/bin/Release/net48, commit b1a26bc);
// no source for this script survived. It was compiled against this engine version.
using Game.Logic.AI;

namespace GameServerScript.AI.Game;

public class DragonWarTerrorGame : APVEGameControl
{
	public override void OnCreated()
	{
		base.Game.SetupMissions("5301,5302,5303,5304");
		base.Game.TotalMissionCount = 4;
	}

	public override void OnPrepated()
	{
	}

	public override int CalculateScoreGrade(int score)
	{
		if (score > 800)
		{
			return 3;
		}
		if (score > 725)
		{
			return 2;
		}
		if (score > 650)
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
