function [bFun, b0Fun, derFun] = conSimPoint2PlaneOLS(prm, cst, obs)

% ------------------------------------------------------------------------------

bFun = @(obs) bFunNested(obs);

    function bBlock = bFunNested(obs)
       
        bBlock = obs.dp;
        
    end

% ------------------------------------------------------------------------------

b0Fun = @(prm, cst) b0FunNested(prm, cst);
    
    function b0Block = b0FunNested(prm, cst)
        
        % Rotation matrices
        R1 = opk2dR(prm.om1, prm.ph1, prm.ka1);
        R2 = opk2dR(prm.om2, prm.ph2, prm.ka2);
        
        % Homogeneous transformation matrix
        H1 = homotrafo(prm.m1, R1, [prm.tx1 prm.ty1 prm.tz1]);
        H2 = homotrafo(prm.m2, R2, [prm.tx2 prm.ty2 prm.tz2]);
        
        % Coordinates
        X1 = [cst.x1 cst.y1 cst.z1];
        X2 = [cst.x2 cst.y2 cst.z2];

        % Normal vector
        n1 = [cst.nx1 cst.ny1 cst.nz1];
        
        % Transformation from cartesian coord. to homogeneous coord.
        X1_h = homocoord(X1);
        X2_h = homocoord(X2);
        n1_h = homocoord(n1);
               
        % Transformation of point clouds
        X1 = homocoord((H1 * X1_h')');
        X2 = homocoord((H2 * X2_h')');
        
        b0Block = dot(X1 - X2, n1, 2);
        
    end

% Derivatives ------------------------------------------------------------------

derFun.prm.om1 = @(prm, cst) derFunNested(prm, cst, 'prm_om1');
derFun.prm.ph1 = @(prm, cst) derFunNested(prm, cst, 'prm_ph1');
derFun.prm.ka1 = @(prm, cst) derFunNested(prm, cst, 'prm_ka1');
derFun.prm.tx1 = @(prm, cst) derFunNested(prm, cst, 'prm_tx1');
derFun.prm.ty1 = @(prm, cst) derFunNested(prm, cst, 'prm_ty1');
derFun.prm.tz1 = @(prm, cst) derFunNested(prm, cst, 'prm_tz1');
derFun.prm.m1  = @(prm, cst) derFunNested(prm, cst, 'prm_m1'); 
                                                               
derFun.prm.om2 = @(prm, cst) derFunNested(prm, cst, 'prm_om2');
derFun.prm.ph2 = @(prm, cst) derFunNested(prm, cst, 'prm_ph2');
derFun.prm.ka2 = @(prm, cst) derFunNested(prm, cst, 'prm_ka2');
derFun.prm.tx2 = @(prm, cst) derFunNested(prm, cst, 'prm_tx2');
derFun.prm.ty2 = @(prm, cst) derFunNested(prm, cst, 'prm_ty2');
derFun.prm.tz2 = @(prm, cst) derFunNested(prm, cst, 'prm_tz2');
derFun.prm.m2  = @(prm, cst) derFunNested(prm, cst, 'prm_m2'); 

    function derFunBlock = derFunNested(prm, cst, var)
        
        switch var
            
            % ------------------------------------------------------------------
            
            case 'prm_om1'
                
                derFunBlock = prm.m1 .* (cst.nz1 .* cst.y1 - cst.ny1 .* cst.z1);
            
            % ------------------------------------------------------------------
            
            case 'prm_ph1'
                
                derFunBlock = prm.m1 .* (cst.nx1 .* cst.z1 - cst.nz1 .* cst.x1);
                
            % ------------------------------------------------------------------
            
            case 'prm_ka1'
                
                derFunBlock = prm.m1 .* (cst.ny1 .* cst.x1 - cst.nx1 .* cst.y1);
            
            % ------------------------------------------------------------------
            
            case 'prm_tx1'
                
                derFunBlock = cst.nx1;
            
            % ------------------------------------------------------------------
            
            case 'prm_ty1'
                
                derFunBlock = cst.ny1;
                
            % ------------------------------------------------------------------
            
            case 'prm_tz1'
                
                derFunBlock = cst.nz1;
            
            % ------------------------------------------------------------------
            
            case 'prm_m1'
                
                R1 = opk2dR(prm.om1, prm.ph1, prm.ka1);
                
                derFunBlock = (cst.nx1.*R1(1,1) + cst.ny1.*R1(2,1) + cst.nz1.*R1(3,1)) .* cst.x1 + ...
                              (cst.nx1.*R1(1,2) + cst.ny1.*R1(2,2) + cst.nz1.*R1(3,2)) .* cst.y1 + ...
                              (cst.nx1.*R1(1,3) + cst.ny1.*R1(2,3) + cst.nz1.*R1(3,3)) .* cst.z1;
            
            % ------------------------------------------------------------------
            % ------------------------------------------------------------------
            
            case 'prm_om2'
                
                derFunBlock = - prm.m2 .* (cst.nz1 .* cst.y2 - cst.ny1 .* cst.z2); % minus!

            % ------------------------------------------------------------------
            
            case 'prm_ph2'
                
                derFunBlock = - prm.m2 .* (cst.nx1 .* cst.z2 - cst.nz1 .* cst.x2); % minus!
                
            % ------------------------------------------------------------------
            
            case 'prm_ka2'
                
                derFunBlock = - prm.m2 .* (cst.ny1 .* cst.x2 - cst.nx1 .* cst.y2); % minus!
            
            % ------------------------------------------------------------------
            
            case 'prm_tx2'
                
                derFunBlock = -cst.nx1; % minus!
            
            % ------------------------------------------------------------------
            
            case 'prm_ty2'
                
                derFunBlock = -cst.ny1; % minus!
            
            % ------------------------------------------------------------------
            
            case 'prm_tz2'
                
                derFunBlock = -cst.nz1; % minus!
            
            % ------------------------------------------------------------------
            
            case 'prm_m2'
                
                R2 = opk2dR(prm.om2, prm.ph2, prm.ka2);
                
                derFunBlock = - ((cst.nx1.*R2(1,1) + cst.ny1.*R2(2,1) + cst.nz1.*R2(3,1)) .* cst.x2 + ... % minus!
                                 (cst.nx1.*R2(1,2) + cst.ny1.*R2(2,2) + cst.nz1.*R2(3,2)) .* cst.y2 + ...
                                 (cst.nx1.*R2(1,3) + cst.ny1.*R2(2,3) + cst.nz1.*R2(3,3)) .* cst.z2);
                
        end
        
    end

end
