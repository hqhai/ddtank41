using Game.Logic.Phy.Object;
using System;

namespace Game.Logic.Actions
{
    public class CallFunctionAction : BaseAction
    {
        private LivingCallBackHandle m_func;

		private Living m_target;

        private LivingCallBack m_callback;

        public CallFunctionAction(LivingCallBackHandle func, Living target, int delay)
			: base(delay)
        {
			m_func = func;
			m_target = target;
        }

        public CallFunctionAction(LivingCallBack callback, int delay)
			: base(delay)
        {
			m_callback = callback;
        }

        protected override void ExecuteImp(BaseGame game, long tick)
        {
			try
			{
				if (m_callback != null)
				{
					m_callback();
				}
				else
				{
					m_func(m_target);
				}
				//Console.WriteLine("func = {0}", m_func);
			}
			finally
			{
				Finish(tick);
			}
        }
    }
}
