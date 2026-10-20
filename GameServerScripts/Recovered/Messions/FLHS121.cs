// Recovered by decompiling the original Game.Server.dll (Road.Service/bin/Release/net48, commit b1a26bc);
// no source for this script survived. It was compiled against this engine version.
using System.Collections.Generic;
using Bussiness;
using Game.Base.Packets;
using Game.Logic;
using Game.Logic.AI;
using Game.Logic.Phy.Object;

namespace GameServerScript.AI.Messions;

public class FLHS121 : AMissionControl
{
	private SimpleNpc someNpc;

	private bool isBeginResult;

	private bool isCreateNpcFirst = true;

	private int createNpcCount;

	private int arightResultCount;

	private int needArightResult = 9;

	private int timeOut = 10;

	private int currQuizID;

	private int enterQuizID;

	private int redNpcID = 4;

	private int maxQuizSize = 10;

	private string[,] resultStr = new string[10, 3]
	{
		{ "", "", "" },
		{ "", "", "" },
		{ "", "", "" },
		{ "", "", "" },
		{ "", "", "" },
		{ "", "", "" },
		{ "", "", "" },
		{ "", "", "" },
		{ "", "", "" },
		{ "", "", "" }
	};

	private string[] distanceStr = new string[20]
	{
		"1", "2", "3", "4", "5", "6", "7", "8", "9", "10",
		"11", "12", "13", "14", "15", "16", "17", "18", "19", "20"
	};

	private int[] arightResult = new int[10];

	private int[] createNpcX = new int[10];

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
		InitNpcCoor();
	}

	public void InitNpcCoor()
	{
		List<int> list = new List<int>();
		int num = -1;
		int num2 = 0;
		for (int i = 0; i < maxQuizSize; i++)
		{
			list.Clear();
			do
			{
				num2 = base.Game.Random.Next(10, 20);
				createNpcX[i] = (num2 + 1) * 100 + 75;
			}
			while (num2 == num);
			num = num2;
			int num3 = base.Game.Random.Next(0, 3);
			resultStr[i, num3] = distanceStr[num2];
			arightResult[i] = num3;
			if (num2 - 1 >= 10 && num2 + 1 < 20)
			{
				list.Add(num2 - 1);
				list.Add(num2 + 1);
			}
			else if (num2 - 1 < 10)
			{
				list.Add(num2 + 1);
				list.Add(num2 + 2);
			}
			else if (num2 + 1 >= 10)
			{
				list.Add(num2 - 1);
				list.Add(num2 - 2);
			}
			for (int j = 0; j < 3; j++)
			{
				if (resultStr[i, j] != distanceStr[num2])
				{
					resultStr[i, j] = distanceStr[list[0]];
					list.RemoveAt(0);
				}
			}
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
			Reset(isFirstNpc: true);
			KillNpc();
			break;
		case 2:
			SendQuizWindow();
			break;
		case 3:
			if (isBeginResult)
			{
				Reset(isFirstNpc: true);
			}
			break;
		case 4:
		{
			if (!isBeginResult)
			{
				break;
			}
			int num = packet.ReadInt();
			int num2 = packet.ReadInt();
			if (num == currQuizID)
			{
				if (num2 == arightResult[num - 1])
				{
					arightResultCount++;
					SendQuizWindow();
				}
				else
				{
					SendQuizWindow();
				}
				enterQuizID = num;
				base.Game.WaitTime(0);
			}
			break;
		}
		case 5:
			if (isBeginResult)
			{
				Reset(isFirstNpc: false);
				SendQuizWindow();
			}
			break;
		}
	}

	public void CreateNpc()
	{
		if (createNpcCount <= maxQuizSize)
		{
			if (isCreateNpcFirst)
			{
				someNpc = base.Game.CreateNpc(redNpcID, 1100, 505, 2);
				someNpc.SetRelateDemagemRect(-25, -55, 45, 55);
				isCreateNpcFirst = false;
				createNpcCount++;
			}
			else
			{
				someNpc = base.Game.CreateNpc(redNpcID, createNpcX[currQuizID], 505, 2);
				someNpc.SetRelateDemagemRect(-25, -55, 45, 55);
				createNpcCount++;
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

	public void Reset(bool isFirstNpc)
	{
		currQuizID = 0;
		enterQuizID = 0;
		arightResultCount = 0;
		createNpcCount = 0;
		if (isFirstNpc)
		{
			isCreateNpcFirst = true;
		}
		else
		{
			isCreateNpcFirst = false;
		}
		isBeginResult = false;
		resultStr = new string[10, 3]
		{
			{ "", "", "" },
			{ "", "", "" },
			{ "", "", "" },
			{ "", "", "" },
			{ "", "", "" },
			{ "", "", "" },
			{ "", "", "" },
			{ "", "", "" },
			{ "", "", "" },
			{ "", "", "" }
		};
		InitNpcCoor();
	}

	private void SendQuizWindow()
	{
		if (currQuizID <= maxQuizSize - 1 && arightResultCount < needArightResult)
		{
			KillNpc();
			CreateNpc();
			isBeginResult = true;
			base.Game.SendOpenPopupQuestionFrame(currQuizID + 1, arightResultCount, needArightResult, maxQuizSize, timeOut, LanguageMgr.GetTranslation("FightLab.caption"), LanguageMgr.GetTranslation("FightLab.question"), resultStr[currQuizID, 0], resultStr[currQuizID, 1], resultStr[currQuizID, 2]);
			currQuizID++;
		}
	}

	public override void OnPrepareNewSession()
	{
		base.OnPrepareNewSession();
		int[] npcIds = new int[1] { redNpcID };
		int[] npcIds2 = new int[3] { redNpcID, redNpcID, redNpcID };
		base.Game.LoadResources(npcIds);
		base.Game.LoadNpcGameOverResources(npcIds2);
		base.Game.SetMap(1137);
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

	public override void OnBeginNewTurn()
	{
		base.OnBeginNewTurn();
	}

	public override bool CanGameOver()
	{
		if (arightResultCount >= needArightResult)
		{
			base.Game.SendClosePopupQuestionFrame();
			base.Game.WaitTime(1000);
			base.Game.IsWin = true;
			return true;
		}
		if (enterQuizID == maxQuizSize)
		{
			base.Game.SendClosePopupQuestionFrame();
			base.Game.WaitTime(1000);
			if (arightResultCount >= needArightResult)
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
		return base.Game.TotalKillCount;
	}

	public override void OnGameOver()
	{
		base.OnGameOver();
		if (arightResultCount >= needArightResult)
		{
			base.Game.IsWin = true;
		}
		else
		{
			base.Game.IsWin = false;
		}
		new List<LoadingFileInfo>();
	}
}
