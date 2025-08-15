import React from 'react';

import styles from './index.module.scss';

const Component = () => {
  return (
    <div className={styles.frame7}>
      <div className={styles.autoWrapper}>
        <div className={styles.statusBarIPhone}>
          <div className={styles.time2}>
            <p className={styles.time}>9:41</p>
          </div>
          <img src="../image/mecama6m-jmffb2x.svg" className={styles.levels} />
        </div>
        <div className={styles.toobarTopIPhone}>
          <div className={styles.fill}>
            <div className={styles.text}>
              <p className={styles.a}>􀯶</p>
            </div>
          </div>
          <img src="../image/mecama6n-zdz4so8.svg" className={styles.blur} />
          <div className={styles.fill2}>
            <div className={styles.symbol1}>
              <p className={styles.symbol}>􀅼</p>
            </div>
          </div>
          <img src="../image/mecama6n-2efhya1.svg" className={styles.blur2} />
          <p className={styles.title}>科目名称</p>
        </div>
      </div>
      <div className={styles.frame}>
        <div className={styles.segmentedControl}>
          <div className={styles.button1}>
            <div className={styles.button}>
              <p className={styles.label}>月</p>
            </div>
          </div>
          <div className={styles.autoWrapper2}>
            <div className={styles.button2}>
              <p className={styles.label2}>6个月</p>
            </div>
            <div className={styles.separator} />
          </div>
          <div className={styles.button3}>
            <p className={styles.label2}>年</p>
          </div>
        </div>
      </div>
      <div className={styles.frame6}>
        <div className={styles.frame3}>
          <p className={styles.text2}>[科目名称]</p>
          <div className={styles.frame2}>
            <p className={styles.text3}>
              [占位文本]Lorem ipsum dolor sit amet, Lorem ipsum dolor sit amet,
              consectetur adipiscing elit, sed do eiusmod tempor incididunt ut
              labore et dolore magna aliqua. Ut enim ad minim veniam
            </p>
          </div>
        </div>
        <div className={styles.frame5}>
          <p className={styles.text4}>选项</p>
          <div className={styles.frame4}>
            <p className={styles.text5}>在摘要中置顶</p>
          </div>
        </div>
      </div>
      <div className={styles.frame1}>
        <div className={styles.titleAndTrailingAcce}>
          <p className={styles.title2}>显示所有数据</p>
          <div className={styles.contentsTrailing}>
            <p className={styles.detail} />
            <p className={styles.drillIn}>􀆊</p>
          </div>
        </div>
        <div className={styles.contents}>
          <div className={styles.aSeparator} />
          <div className={styles.titleAndTrailingAcce2}>
            <p className={styles.title2}>编辑科目</p>
            <div className={styles.contentsTrailing}>
              <p className={styles.detail} />
              <p className={styles.drillIn}>􀆊</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default Component;
