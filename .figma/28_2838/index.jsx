import React from 'react';

import styles from './index.module.scss';

const Component = () => {
  return (
    <div className={styles.component}>
      <div className={styles.frame4}>
        <div className={styles.frame2}>
          <p className={styles.text}>􀉪</p>
          <div className={styles.frame}>
            <p className={styles.text}>班级</p>
            <p className={styles.text}>排名</p>
          </div>
        </div>
        <div className={styles.frame3}>
          <p className={styles.text2}>6月25日</p>
          <p className={styles.text2}>􀆊</p>
        </div>
      </div>
      <div className={styles.frame8}>
        <div className={styles.frame6}>
          <p className={styles.text3}>最新</p>
          <div className={styles.frame5}>
            <p className={styles.text4}>10</p>
            <div className={styles.frame22}>
              <p className={styles.a}>/</p>
              <div className={styles.frame1}>
                <p className={styles.text5}>20</p>
                <p className={styles.text6}>人</p>
              </div>
            </div>
          </div>
        </div>
        <div className={styles.frame7}>
          <p className={styles.text7}>图表预留处</p>
        </div>
      </div>
    </div>
  );
}

export default Component;
