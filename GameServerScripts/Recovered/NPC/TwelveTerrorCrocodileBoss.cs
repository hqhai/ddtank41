// Recovered by decompiling the original Game.Server.dll (Road.Service/bin/Release/net48, commit b1a26bc);
// no source for this script survived. It was compiled against this engine version.
using Game.Logic;
using Game.Logic.AI;
using Game.Logic.Phy.Object;

namespace GameServerScript.AI.NPC;

public class TwelveTerrorCrocodileBoss : ABrain
{
	private int m_attackTurn;

	private int npcID = 12307;

	private Player target;

	private PhysicalObj moive;

	private PhysicalObj m_moive;

	private static string[] AllAttackChat = new string[3] { "Xem các ngươi！！<br/>lợi hại như thế nào", "Lưỡi kiếm của ta！", "Nén không được đâu！！" };

	private static string[] ShootChat = new string[3] { "让你知道什么叫百发百中！", "送你一个球~你可要接好啦", "你们这群无知的低等庶民" };

	private static string[] ShootedChat = new string[2] { "哎呀~~你们为什么要攻击我？<br/>我在干什么？", "噢~~好痛!我为什么要战斗？<br/>我必须战斗…" };

	private static string[] AddBooldChat = new string[3] { "扭啊扭~<br/>扭啊扭~~", "哈利路亚~<br/>路亚路亚~~", "呀呀呀，<br/>好舒服啊！" };

	private static string[] KillAttackChat = new string[1] { "君临天下！！" };

	public override void OnBeginSelfTurn()
	{
		base.OnBeginSelfTurn();
	}

	public override void OnBeginNewTurn()
	{
		base.OnBeginNewTurn();
		m_body.CurrentDamagePlus = 1f;
		m_body.CurrentShootMinus = 1f;
		((PVEGame)base.Game).SendLivingActionMapping(base.Body, "cry", "cryB");
		((PVEGame)base.Game).SendLivingActionMapping(base.Body, "die", "dieB");
	}

	public override void OnCreated()
	{
		base.OnCreated();
	}

	public override void OnStartAttacking()
	{
		base.OnStartAttacking();
		target = base.Game.FindRandomPlayer();
		if (m_attackTurn == 0)
		{
			Walk2();
			m_attackTurn++;
		}
		else if (m_attackTurn == 1)
		{
			PersonalAttack();
			m_attackTurn++;
		}
		else if (m_attackTurn == 2)
		{
			AllAttack();
			m_attackTurn++;
		}
		else if (m_attackTurn == 3)
		{
			DameOneKill();
			m_attackTurn++;
		}
		else if (m_attackTurn == 4)
		{
			InDameOneKill();
			m_attackTurn++;
		}
		else
		{
			Walk();
			m_attackTurn = 0;
		}
	}

	private void DameOneKill()
	{
		int num = base.Game.Random.Next(0, AllAttackChat.Length);
		base.Body.Say(AllAttackChat[num], 1, 0);
		base.Body.PlayMovie("beatD", 2000, 0);
		base.Body.CallFuction(CallPhysicalObj, 3400);
	}

	private void InDameOneKill()
	{
		int num = base.Game.Random.Next(0, AllAttackChat.Length);
		base.Body.Say(AllAttackChat[num], 1, 0);
		base.Body.PlayMovie("beatD", 2000, 0);
		base.Body.CallFuction(CallPhysicalObjBeat, 3400);
	}

	private void CallPhysicalObj()
	{
		moive = ((PVEGame)base.Game).Createlayer(target.X, target.Y, "moive", "asset.game.nine.biaoji", "", 2, 0);
	}

	private void CallPhysicalObjBeat()
	{
		m_moive = ((PVEGame)base.Game).Createlayer(moive.X, moive.Y, "moive", "asset.game.nine.dapao", "beatA", 1, 0);
		((PVEGame)base.Game).SendGameFocus(moive.X, moive.Y, 1, 0, 0);
		base.Body.CurrentDamagePlus = 1f;
		base.Body.RangeAttacking(moive.X - 200, moive.X + 200, "cryA", 2000, null);
		if (moive != null)
		{
			base.Game.RemovePhysicalObj(moive, sendToClient: true);
			moive = null;
		}
	}

	private void AllAttack()
	{
		int num = base.Game.Random.Next(0, AllAttackChat.Length);
		base.Body.Say(AllAttackChat[num], 1, 0);
		base.Body.PlayMovie("beatC", 2000, 0);
		foreach (Player allFightPlayer in base.Game.GetAllFightPlayers())
		{
			base.Body.BeatDirect(allFightPlayer, "", 4000, 1, 1);
		}
	}

	private void Walk()
	{
		int num = 0;
		num = ((base.Body.X <= target.X) ? (target.X - 150) : (target.X + 150));
		int delayCallback = base.Game.GetDelayDistance(base.Body.X, num, 8) + 500;
		base.Body.MoveTo(num, base.Body.Y, "walk", 9, "", 1200, NextAttack, delayCallback);
	}

	private void Walk2()
	{
		int num = base.Game.Random.Next(1261, 1350);
		int delayCallback = base.Game.GetDelayDistance(base.Body.X, num, 8) + 1000;
		base.Body.MoveTo(num, base.Body.Y, "walk", 8, "", 1200, CreateChild, delayCallback);
	}

	private void NextAttack()
	{
		base.Body.ChangeDirection(target, 0);
		base.Body.PlayMovie("beatB", 0, 3000);
		base.Body.RangeAttacking(target.X - 150, target.X + 150, "cry", 3000, null);
	}

	private void PersonalAttack()
	{
		base.Body.PlayMovie("beatA", 1200, 3000);
		base.Body.CallFuction(CallBall, 2700);
	}

	private void CallBall()
	{
		base.Body.RangeAttacking(target.X - 100, target.X + 100, "cry", 1000, null);
	}

	public void CreateChild()
	{
		base.Body.Say("Lựu đạn đâu ra cho anh", 1, 0);
		base.Body.Direction = base.Game.FindlivingbyDir(base.Body);
		base.Body.PlayMovie("beatD", 0, 1500);
		int[] array = new int[4] { 450, 750, 1000, 1350 };
		for (int i = 0; i < 4; i++)
		{
			((SimpleBoss)base.Body).CreateChild(npcID, array[i], 700, -1, showBlood: true, ((PVEGame)base.Game).BaseLivingConfig());
		}
		SimpleNpc[] nPCLivingWithID = base.Game.GetNPCLivingWithID(npcID);
		for (int j = 0; j < nPCLivingWithID.Length; j++)
		{
			nPCLivingWithID[j].Properties1 = 1;
		}
	}

	public override void OnStopAttacking()
	{
		base.OnStopAttacking();
		if (m_moive != null)
		{
			base.Game.RemovePhysicalObj(m_moive, sendToClient: true);
			m_moive = null;
		}
	}

	public override void OnAfterTakeDamage(Living player)
	{
		base.OnAfterTakeDamage(player);
		if (player is SimpleNpc)
		{
			((PVEGame)base.Game).SendLivingActionMapping(base.Body, "cry", "cryA");
			((PVEGame)base.Game).SendLivingActionMapping(base.Body, "die", "dieA");
		}
		else
		{
			((PVEGame)base.Game).SendLivingActionMapping(base.Body, "cry", "cryB");
			((PVEGame)base.Game).SendLivingActionMapping(base.Body, "die", "dieB");
		}
	}
}
