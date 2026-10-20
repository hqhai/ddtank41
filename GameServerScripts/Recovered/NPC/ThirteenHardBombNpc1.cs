// Recovered by decompiling the original Game.Server.dll (Road.Service/bin/Release/net48, commit b1a26bc);
// no source for this script survived. It was compiled against this engine version.
using Game.Logic.AI;
using Game.Logic.Phy.Object;

namespace GameServerScript.AI.NPC;

public class ThirteenHardBombNpc1 : ABrain
{
	private Player m_target;

	private int m_targetDis;

	public override void OnBeginSelfTurn()
	{
		base.OnBeginSelfTurn();
	}

	public override void OnBeginNewTurn()
	{
		base.OnBeginNewTurn();
		base.Body.CurrentDamagePlus = 2f;
		base.Body.CurrentShootMinus = 2f;
	}

	public override void OnCreated()
	{
		base.OnCreated();
	}

	public override void OnStartAttacking()
	{
		base.OnStartAttacking();
		base.Body.CurrentDamagePlus = 2f;
		base.Body.CurrentShootMinus = 2f;
		if (base.Body.Properties1 > 0)
		{
			base.Body.Properties1--;
			return;
		}
		m_target = base.Game.FindNearestPlayer(base.Body.X, base.Body.Y);
		m_targetDis = (int)m_target.Distance(base.Body.X, base.Body.Y);
		if (m_targetDis < 50)
		{
			base.Body.PlayMovie("beatA", 100, 0);
			base.Body.RangeAttacking(base.Body.X - 100, base.Body.X + 100, "cry", 1500, null);
			base.Body.Die(1000);
		}
		else
		{
			MoveToPlayer(m_target);
		}
	}

	public override void OnStopAttacking()
	{
		base.OnStopAttacking();
	}

	public void MoveToPlayer(Player player)
	{
		int num = base.Game.Random.Next(((SimpleNpc)base.Body).NpcInfo.MoveMin, ((SimpleNpc)base.Body).NpcInfo.MoveMax);
		int num2 = 0;
		if (player.X > base.Body.X)
		{
			if (base.Body.X + num >= player.X)
			{
				num2 = base.Game.GetDelayDistance(base.Body.X, player.X - 10, 3) + 500;
				base.Body.MoveTo(player.X - 50, base.Body.Y, "walk", ((SimpleNpc)base.Body).NpcInfo.speed, "", 2000, Beat, num2);
			}
			else
			{
				num2 = base.Game.GetDelayDistance(base.Body.X, base.Body.X + num, 3) + 500;
				base.Body.MoveTo(base.Body.X + num, base.Body.Y, "walk", ((SimpleNpc)base.Body).NpcInfo.speed, "", 2000, Beat, num2);
			}
		}
		else if (base.Body.X - num <= player.X)
		{
			num2 = base.Game.GetDelayDistance(base.Body.X, player.X + 10, 3) + 500;
			base.Body.MoveTo(player.X + 50, base.Body.Y, "walk", ((SimpleNpc)base.Body).NpcInfo.speed, "", 2000, Beat, num2);
		}
		else
		{
			num2 = base.Game.GetDelayDistance(base.Body.X, base.Body.X - num, 3) + 500;
			base.Body.MoveTo(base.Body.X - num, base.Body.Y, "walk", ((SimpleNpc)base.Body).NpcInfo.speed, "", 2000, Beat, num2);
		}
	}

	public void Beat()
	{
		m_targetDis = (int)m_target.Distance(base.Body.X, base.Body.Y);
		if (m_targetDis <= 50)
		{
			base.Body.PlayMovie("beatA", 100, 0);
			base.Body.RangeAttacking(base.Body.X - 100, base.Body.X + 100, "cry", 1500, null);
			base.Body.Die(2000);
		}
	}
}
