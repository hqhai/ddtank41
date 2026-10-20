// Recovered by decompiling the original Game.Server.dll (Road.Service/bin/Release/net48, commit b1a26bc);
// no source for this script survived. It was compiled against this engine version.
using Game.Logic;
using Game.Logic.AI;
using Game.Logic.Phy.Object;

namespace GameServerScript.AI.NPC;

public class TwelveNormalCaptainBoss : ABrain
{
	private int m_attackTurn;

	private Player m_target;

	private int m_dis;

	public override void OnBeginSelfTurn()
	{
		base.OnBeginSelfTurn();
	}

	public override void OnBeginNewTurn()
	{
		base.OnBeginNewTurn();
	}

	public override void OnCreated()
	{
		base.OnCreated();
		base.Body.MaxBeatDis = 190;
	}

	public override void OnStartAttacking()
	{
		base.OnStartAttacking();
		if (base.Body.Properties1 > 0)
		{
			base.Body.Properties1--;
		}
		else if (m_attackTurn == 0)
		{
			SayToPlayer();
			m_attackTurn = 1;
		}
		else
		{
			MoveToPlayerAndAttack();
		}
	}

	private void SayToPlayer()
	{
		(base.Game as PVEGame).SendObjectFocus(base.Body, 0, 1000, 0);
		base.Body.FallFrom(base.Body.X, base.Body.Y, "", 2000, 0, 0, null);
		base.Body.Say("Ta sẽ cho các người biết thế nào là lợi hại của ta!", 0, 2500, 2000);
	}

	private void MoveToPlayerAndAttack()
	{
		m_target = base.Game.FindNearestPlayer(base.Body.X, base.Body.Y);
		if (m_target != null && m_target.IsLiving)
		{
			m_dis = (int)m_target.Distance(base.Body.X, base.Body.Y);
			if (m_dis > base.Body.MaxBeatDis)
			{
				base.Body.CallFuction(MoveToTarget, 1000);
			}
			else
			{
				base.Body.CallFuction(Beat, 1000);
			}
		}
	}

	private void MoveToTarget()
	{
		int num = base.Game.Random.Next(((SimpleBoss)base.Body).NpcInfo.MoveMax, ((SimpleBoss)base.Body).NpcInfo.MoveMax);
		if (m_dis < num)
		{
			num = m_dis;
		}
		int num2 = ((base.Body.Direction == -1) ? (base.Body.X - num) : (base.Body.X + num));
		int delayCallback = base.Game.GetDelayDistance(base.Body.X, num2, 3) + 1000;
		base.Body.MoveTo(num2, base.Body.Y, "walk", ((SimpleBoss)base.Body).NpcInfo.speed, "", 1200, Beat, delayCallback);
	}

	public override void OnAfterTakedFrozen()
	{
		base.OnAfterTakedFrozen();
		base.Body.Properties1 = 2;
	}

	private void Beat()
	{
		base.Body.Beat(m_target, "beatA", 100, 0, 500, 1, 1);
	}

	public override void OnStopAttacking()
	{
		base.OnStopAttacking();
	}
}
