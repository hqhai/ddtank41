// Recovered by decompiling the original Game.Server.dll (Road.Service/bin/Release/net48, commit b1a26bc);
// no source for this script survived. It was compiled against this engine version.
using System;
using Game.Logic;
using Game.Logic.AI;
using Game.Logic.Phy.Object;

namespace GameServerScript.AI.NPC;

public class TwelveHardGunBoss : ABrain
{
	private int BossID = 12208;

	private static Random random = new Random();

	private static string[] listChat = new string[2] { "Hãy đánh bại Cá Sấu!!", "Tiêu diệt Nhóc lựu đạn để tăng hỏa lực" };

	public static string GetOneChat()
	{
		int num = random.Next(0, listChat.Length);
		return listChat[num];
	}

	public override void OnBeginNewTurn()
	{
		m_body.CurrentDamagePlus = 1f;
		m_body.CurrentShootMinus = 1f;
		if (m_body.IsSay)
		{
			string oneChat = GetOneChat();
			int delay = base.Game.Random.Next(0, 5000);
			m_body.Say(oneChat, 0, delay);
		}
	}

	public override void OnBeginSelfTurn()
	{
	}

	public override void OnCreated()
	{
	}

	public override void OnStartAttacking()
	{
		MoveBeat();
	}

	public void MoveBeat()
	{
		((PVEGame)base.Game).SendGameFocus(0, 800, 1, 0, 2000);
		base.Body.Say("Thử cái này xem", 0, 0);
		base.Body.PlayMovie("beatA", 0, 2900);
		base.Body.CallFuction(dame, 2900);
	}

	private void dame()
	{
		SimpleBoss simpleBoss = ((PVEGame)base.Game).FindBossWithID(BossID);
		simpleBoss.Properties3 = int.Parse(simpleBoss.Properties3.ToString()) + base.Body.ShootCount;
		for (int i = 0; i < base.Body.ShootCount; i++)
		{
			if (base.Body.ShootPoint(simpleBoss.X + 120, simpleBoss.Y - 125, 88, 1000, 10000, 1, 1f, 500 + i * 1000))
			{
				base.Body.PlayMovie("beatB", 500 + 1000 * i, 0);
			}
		}
		base.Body.ShootCount = 0;
		base.Body.Config.IsTurn = false;
	}

	public override void OnStopAttacking()
	{
	}
}
