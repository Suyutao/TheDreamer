import React from 'react';

import styles from './index.module.scss';

const Component = () => {
  return (
    <div className={styles.component}>
      <div className={styles.frame3}>
        <div className={styles.frame1}>
          <p className={styles.text}>当前</p>
          <div className={styles.frame2}>
            <div className={styles.frame8}>
              <p className={styles.a}>􀫓</p>
              <p className={styles.title}>信息技术</p>
            </div>
            <p className={styles.a2019}>20:19</p>
          </div>
        </div>
        <div className={styles.frame10}>
          <div className={styles.track}>
            <div className={styles.filled} />
          </div>
          <div className={styles.frame}>
            <p className={styles.subtitle}>13:50</p>
            <p className={styles.subtitle}>14:30</p>
          </div>
        </div>
      </div>
    </div>
  );
}

export default Component;
