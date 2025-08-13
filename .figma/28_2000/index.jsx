import React from 'react';

import styles from './index.module.scss';

const Component = () => {
  return (
    <div className={styles.component}>
      <div className={styles.frame3}>
        <div className={styles.frame}>
          <p className={styles.text}>􀅮</p>
          <p className={styles.text}>数学</p>
        </div>
        <div className={styles.frame2}>
          <p className={styles.text2}>6月24日</p>
          <p className={styles.text2}>􀆊</p>
        </div>
      </div>
      <div className={styles.frame7}>
        <div className={styles.frame5}>
          <p className={styles.text3}>最新</p>
          <div className={styles.frame4}>
            <p className={styles.text4}>125</p>
            <p className={styles.text5}>分</p>
          </div>
        </div>
        <div className={styles.frame6}>
          <p className={styles.text6}>图表预留处</p>
        </div>
      </div>
    </div>
  );
}

export default Component;
