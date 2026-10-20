// Recovered by decompiling the original Game.Server.dll (Road.Service/bin/Release/net48, commit b1a26bc);
// no source for this script survived. It was compiled against this engine version.
using System.Collections.Generic;
using System.Drawing;
using Game.Base.Packets;
using Game.Logic;
using Game.Logic.AI;
using Game.Logic.Actions;
using Game.Logic.Phy.Object;

namespace GameServerScript.AI.Messions;

public class FLSS105 : AMissionControl
{
	private SimpleNpc someNpc;

	private bool isBeginHit;

	private bool isCreateNpcFirst;

	private int createNpcCount;

	private int hitCount;

	private int needHitCount = 3;

	private int currTurnID;

	private int redNpcID = 6;

	private int maxTurnSize = 10;

	private Point[] createNpcX = new Point[18]
	{
		new Point(77, 573),
		new Point(109, 573),
		new Point(141, 573),
		new Point(173, 573),
		new Point(205, 573),
		new Point(237, 573),
		new Point(442, 1271),
		new Point(479, 1271),
		new Point(516, 1271),
		new Point(553, 1271),
		new Point(590, 1271),
		new Point(627, 1271),
		new Point(866, 769),
		new Point(899, 769),
		new Point(932, 769),
		new Point(965, 769),
		new Point(998, 769),
		new Point(1031, 769)
	};

	public override int CalculateScoreGrade(int score)
	{
		base.CalculateScoreGrade(score);
		if (score > 1870)
		{
			return 3;
		}
		if (score > 1825)
		{
			return 2;
		}
		if (score > 1780)
		{
			return 1;
		}
		return 0;
	}

	public override void OnPrepareNewGame()
	{
		base.OnPrepareNewGame();
	}

	public override void OnBeginNewTurn()
	{
		base.OnBeginNewTurn();
		if (isBeginHit)
		{
			KillNpc();
			CreateNpc();
		}
	}

	public override void OnGeneralCommand(GSPacketIn packet)
	{
		switch (packet.ReadInt())
		{
		case 0:
			CreateNpc();
			break;
		case 1:
			isBeginHit = false;
			Reset();
			KillNpc();
			break;
		case 2:
			isBeginHit = true;
			someNpc = null;
			base.Game.AddAction(new LivingCallFunctionAction(null, Skip, 4000));
			break;
		}
	}

	public void Skip()
	{
		base.Game.CurrentPlayer.Skip(0);
	}

	public void CreateNpc()
	{
		if (createNpcCount <= maxTurnSize)
		{
			LivingConfig livingConfig = base.Game.BaseLivingConfig();
			livingConfig.IsTurn = false;
			livingConfig.IsFly = true;
			if (isCreateNpcFirst)
			{
				someNpc = base.Game.CreateNpc(redNpcID, 932, 769, 2, 1, livingConfig);
				isCreateNpcFirst = false;
				base.Game.WaitTime(0);
			}
			else
			{
				int num = base.Game.Random.Next(0, createNpcX.Length);
				someNpc = base.Game.CreateNpc(redNpcID, createNpcX[num].X, createNpcX[num].Y, 2, 1, livingConfig);
				createNpcCount++;
				currTurnID++;
				base.Game.WaitTime(0);
			}
		}
	}

	public void KillNpc()
	{
		if (someNpc != null && someNpc.IsLiving)
		{
			base.Game.RemoveLiving(someNpc, sendToClient: true);
			someNpc = null;
		}
	}

	public void Reset()
	{
		currTurnID = 0;
		hitCount = 0;
		isCreateNpcFirst = true;
		isBeginHit = false;
	}

	public override void OnPrepareNewSession()
	{
		base.OnPrepareNewSession();
		int[] npcIds = new int[1] { redNpcID };
		int[] npcIds2 = new int[3] { redNpcID, redNpcID, redNpcID };
		base.Game.LoadResources(npcIds);
		base.Game.LoadNpcGameOverResources(npcIds2);
		base.Game.SetMap(1138);
	}

	public override void OnStartGame()
	{
		base.OnStartGame();
	}

	public override void OnNewTurnStarted()
	{
		base.OnNewTurnStarted();
		if (base.Game.CurrentLiving != null)
		{
			((Player)base.Game.CurrentLiving).Seal((Player)base.Game.CurrentLiving, 0, 0);
		}
	}

	public override bool CanGameOver()
	{
		if (isBeginHit && someNpc != null && !someNpc.IsLiving)
		{
			hitCount++;
		}
		if (hitCount >= needHitCount)
		{
			base.Game.IsWin = true;
			return true;
		}
		if (createNpcCount == maxTurnSize)
		{
			if (hitCount >= needHitCount)
			{
				base.Game.IsWin = true;
			}
			else
			{
				base.Game.IsWin = false;
			}
			return true;
		}
		return false;
	}

	public override int UpdateUIData()
	{
		base.Game.Param1 = createNpcCount;
		return hitCount;
	}

	public override void OnGameOver()
	{
		base.OnGameOver();
		new List<LoadingFileInfo>();
	}
}
