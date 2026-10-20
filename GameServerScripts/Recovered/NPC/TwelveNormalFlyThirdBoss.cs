// Recovered by decompiling the original Game.Server.dll (Road.Service/bin/Release/net48, commit b1a26bc);
// no source for this script survived. It was compiled against this engine version.
using System.Collections.Generic;
using Game.Logic;
using Game.Logic.AI;
using Game.Logic.Effects;
using Game.Logic.Phy.Object;

namespace GameServerScript.AI.NPC;

public class TwelveNormalFlyThirdBoss : ABrain
{
	private int m_attackTurn;

	public int currentCount;

	public int Dander;

	private PhysicalObj Hole;

	private int npcID = 1009;

	protected List<Living> m_livings;

	public List<SimpleNpc> Children = new List<SimpleNpc>();

	private static string[] ElectricChat = new string[3] { "Nguồn điện từ 10 ngàn volt", "Điện từ trường cấp 10", "Cảm giác khó tả khi bị giựt điện phải không" };

	private static string[] HoleChat = new string[2] { "Lỗ hổng không gian", "Lốc xoáy vũ trụ" };

	private static string[] DiamondChat = new string[2] { "Ăn này !!!!!!", "Hút này" };

	private static string[] VoltTakeChat = new string[2] { "Nếm thử chiêu này xem !!!", "Cận thận chứ" };

	private static string[] ShootedChat = new string[2] { "Hiha…", "Hello mấy bạn…" };

	private static string[] JumpChat = new string[3] { "Gì ó！", "Hello lại là mình đây！", "Ya hoo！" };

	private static string[] KillAttackChat = new string[1] { "MrD！！" };

	public override void OnBeginSelfTurn()
	{
		base.OnBeginSelfTurn();
	}

	public override void OnBeginNewTurn()
	{
		base.OnBeginNewTurn();
		base.Body.CurrentDamagePlus = 1f;
		base.Body.CurrentShootMinus = 1f;
		m_attackTurn++;
	}

	public override void OnCreated()
	{
		base.OnCreated();
	}

	public override void OnStartAttacking()
	{
		base.OnStartAttacking();
		int x = base.Game.Random.Next(600, 1300);
		int y = base.Game.Random.Next(300, 400);
		if (m_attackTurn == 1)
		{
			base.Body.MoveTo(x, y, "fly", 1000, "fly", 8);
			base.Body.CallFuction(HoleAttack, 3000);
		}
		else if (m_attackTurn == 2)
		{
			base.Body.MoveTo(x, y, "fly", 1000, "fly", 8);
			base.Body.CallFuction(ReadyElectricAttack, 3000);
		}
		else if (m_attackTurn == 3)
		{
			base.Body.MoveTo(x, y, "fly", 1000, "fly", 8);
			base.Body.CallFuction(ReadyDiamondAttack, 3000);
		}
		else
		{
			base.Body.MoveTo(x, y, "fly", 1000, "fly", 8);
			base.Body.CallFuction(ReadySockAttack, 3000);
			m_attackTurn = 0;
		}
	}

	public override void OnStopAttacking()
	{
		base.OnStopAttacking();
	}

	private void KillAttack(int fx)
	{
	}

	private void AllAttack()
	{
	}

	private void ReadySockAttack()
	{
		base.Body.PlayMovie("beatA", 5800, 0);
		base.Body.Say("Hãy chết đi !!!!", 1, 0);
		base.Body.CallFuction(SockAttack, 5800);
	}

	private void SockAttack()
	{
		foreach (Player allFightPlayer in base.Game.GetAllFightPlayers())
		{
			if (allFightPlayer.IsLiving)
			{
				base.Body.RangeAttacking(allFightPlayer.X - 200, allFightPlayer.X + 200, "cryA", 2000, null);
				Hole = ((PVEGame)base.Game).Createlayer(allFightPlayer.X, allFightPlayer.Y, "moive", "asset.game.nine.dianxipao", "", 1, 0);
			}
		}
	}

	private void ReadyDiamondAttack()
	{
		base.Body.PlayMovie("beatC", 5800, 0);
		base.Body.Say("Hãy tiếp chiêu !!!!", 1, 0);
		base.Body.CallFuction(DiamondAttack, 5800);
	}

	private void DiamondAttack()
	{
		foreach (Player allFightPlayer in base.Game.GetAllFightPlayers())
		{
			if (allFightPlayer.IsLiving)
			{
				base.Body.RangeAttacking(allFightPlayer.X - 200, allFightPlayer.X + 200, "cryA", 2000, null);
				Hole = ((PVEGame)base.Game).Createlayer(allFightPlayer.X, allFightPlayer.Y, "moive", "asset.game.nine.fengyin", "", 1, 0);
				Hole = ((PVEGame)base.Game).Createlayer(allFightPlayer.X, allFightPlayer.Y, "moive", "asset.game.nine.fengyin", "", 1, 0);
				allFightPlayer.AddEffect(new ContinueReduceBloodEffect(2, 4000, null), 0);
			}
		}
	}

	private void ReadyElectricAttack()
	{
		base.Body.PlayMovie("beatB", 6000, 0);
		int num = base.Game.Random.Next(0, ElectricChat.Length);
		base.Body.Say(ElectricChat[num], 1, 0);
		base.Body.CallFuction(ElectricAttack, 6000);
	}

	private void ElectricAttack()
	{
		foreach (Player allFightPlayer in base.Game.GetAllFightPlayers())
		{
			if (allFightPlayer.IsLiving)
			{
				base.Body.RangeAttacking(allFightPlayer.X - 200, allFightPlayer.X + 200, "cryA", 2000, null);
				Hole = ((PVEGame)base.Game).Createlayer(allFightPlayer.X, allFightPlayer.Y, "moive", "asset.game.nine.dianxipao", "", 1, 0);
			}
		}
	}

	private void HoleAttack()
	{
		base.Body.PlayMovie("beatD", 1000, 0);
		int num = base.Game.Random.Next(0, HoleChat.Length);
		base.Body.Say(HoleChat[num], 1, 0);
		foreach (Player allFightPlayer in base.Game.GetAllFightPlayers())
		{
			int num2 = base.Game.Random.Next(3000, 4000);
			int x = base.Game.Random.Next(400, 820);
			int y = base.Game.Random.Next(400, 600);
			base.Body.CurrentDamagePlus = 1f;
			Hole = ((PVEGame)base.Game).Createlayer(x, y, "moive", "asset.game.nine.heidong", "", 1, 0);
			allFightPlayer.SetXY(Hole.X, Hole.Y);
			base.Body.RangeAttacking(allFightPlayer.X - 200, allFightPlayer.X + 200, "cryA", 2000, null);
			allFightPlayer.ReducedBlood(-num2);
		}
	}
}
