// Recovered by decompiling the original Game.Server.dll (Road.Service/bin/Release/net48, commit b1a26bc);
// no source for this script survived. It was compiled against this engine version.
using System.Collections.Generic;
using Game.Logic;
using Game.Logic.AI;
using Game.Logic.Phy.Object;

namespace GameServerScript.AI.Messions;

public class TVN12001 : AMissionControl
{
	private List<SimpleNpc> SomeNpc = new List<SimpleNpc>();

	private SimpleBoss npc;

	private SimpleBoss m_boss;

	private int CountBigVolverine = 2;

	private int CountVolverine = 3;

	private int BossID = 12103;

	private int BigVolverineNPC = 12102;

	private int VolverineNPC = 12101;

	private int ChickenHelp = 12104;

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

	public override void OnPrepareNewSession()
	{
		base.OnPrepareNewSession();
		int[] npcIds = new int[4] { BossID, ChickenHelp, VolverineNPC, BigVolverineNPC };
		base.Game.LoadResources(npcIds);
		base.Game.LoadNpcGameOverResources(npcIds);
		base.Game.SetMap(1207);
	}

	public override void OnPrepareStartGame()
	{
		base.OnPrepareStartGame();
		LivingConfig livingConfig = base.Game.BaseLivingConfig();
		livingConfig.IsHelper = true;
		livingConfig.IsTurn = false;
		livingConfig.CanTakeDamage = false;
		npc = base.Game.CreateBoss(ChickenHelp, 904, 700, -1, 0, "", livingConfig);
		npc.PlayMovie("standA", 0, 0);
		npc.FallFrom(npc.X, npc.Y, "", 0, 0, 1230, null);
	}

	public override void OnStartGame()
	{
		base.OnStartGame();
		CreateNPC();
	}

	private int CanCreateNPC()
	{
		int num = 0;
		foreach (SimpleNpc item in SomeNpc)
		{
			if (item.IsLiving)
			{
				num++;
			}
		}
		return num;
	}

	private void CreateNPC()
	{
		for (int i = 0; i < CountBigVolverine; i++)
		{
			SomeNpc.Add(base.Game.CreateNpc(BigVolverineNPC, 1735, 766, 1, -1));
		}
		for (int j = 0; j < CountVolverine; j++)
		{
			SomeNpc.Add(base.Game.CreateNpc(VolverineNPC, 1735, 766, 1, -1));
		}
	}

	public override void OnNewTurnStarted()
	{
		base.OnNewTurnStarted();
		if (CanCreateNPC() <= 0 && base.Game.TotalKillCount < base.Game.TotalCount)
		{
			base.Game.PveGameDelay = 0;
			CreateNPC();
		}
		foreach (SimpleNpc item in SomeNpc)
		{
			item.NpcInfo.speed = 4;
		}
		if (base.Game.TurnIndex == 5)
		{
			LivingConfig livingConfig = base.Game.BaseLivingConfig();
			livingConfig.CanFrost = true;
			m_boss = base.Game.CreateBoss(BossID, 100, 700, 1, 2, "", livingConfig);
			m_boss.FallFrom(100, 700, "", 0, 0, 1000, null);
			m_boss.SetRelateDemagemRect(-41, -187, 83, 140);
			m_boss.DoAction = 3;
		}
	}

	public override void OnBeginNewTurn()
	{
		base.OnBeginNewTurn();
	}

	public override bool CanGameOver()
	{
		base.CanGameOver();
		if (base.Game.TurnIndex > base.Game.TotalTurn)
		{
			return true;
		}
		if (CanCreateNPC() <= 0 && base.Game.TotalKillCount >= base.Game.TotalCount)
		{
			return true;
		}
		if (base.Game.GetAllLivingPlayers().Count <= 0)
		{
			return true;
		}
		return false;
	}

	private void Ending()
	{
		base.Game.CanEndGame = true;
	}

	public override void OnPrepareGameOver()
	{
		base.OnPrepareGameOver();
		if (CanCreateNPC() <= 0 && base.Game.TotalKillCount >= base.Game.TotalCount)
		{
			base.Game.SendObjectFocus(m_boss, 1, 1, 1);
			m_boss.PlayMovie("die", 500, 500);
			m_boss.Say("Không thể nào...", 0, 500);
			m_boss.CallFuction(Ending, 2000);
		}
		else if (base.Game.TurnIndex > base.Game.TotalTurn || base.Game.GetAllLivingPlayers().Count <= 0)
		{
			base.Game.CanEndGame = true;
		}
	}

	public override int UpdateUIData()
	{
		return base.Game.TotalKillCount;
	}

	public override void OnGameOver()
	{
		if (CanCreateNPC() <= 0 && base.Game.TotalKillCount >= base.Game.TotalCount)
		{
			base.Game.IsWin = true;
		}
		else
		{
			base.Game.IsWin = false;
		}
	}
}
